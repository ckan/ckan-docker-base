#!/bin/bash
set -e

set_vars() {
    local ckan_version_ref="$1"
    local env="$2"
    local python_version="$3"

    ckan_version=$(cat "ckan-$ckan_version_ref/VERSION.txt")
    if [ -z "$python_version" ]; then
        PYTHON_VERSION=$(cat "ckan-$ckan_version_ref/PYTHON_VERSION.txt")
    else
        PYTHON_VERSION="$python_version"
    fi

    python_dockerfile=Dockerfile.py$PYTHON_VERSION
    tag_name="ckan/ckan-$env:$ckan_version"
    python_tag_name="ckan/ckan-$env:$ckan_version-py$PYTHON_VERSION"
    if [[ "$ckan_version" == "master" || "$ckan_version" == dev* ]]; then
        ckan_tag=$ckan_version
        alt_tag_name=$tag_name
        python_alt_tag_name=$python_tag_name
    else
        ckan_tag=ckan-$ckan_version
        ckan_version_major=$(echo "$ckan_version" | cut -d'.' -f1)
        ckan_version_minor=$(echo "$ckan_version" | cut -d'.' -f2)
        alt_tag_name="ckan/ckan-$env:$ckan_version_major.$ckan_version_minor"
        python_alt_tag_name="ckan/ckan-$env:$ckan_version_major.$ckan_version_minor-py$PYTHON_VERSION"
    fi
}

build_images() {
    local ckan_version_ref="$1"
    local env="$2"
    local python_version="$3"

    set_vars "$ckan_version_ref" "$env" "$python_version"

    if [ -f "ckan-$ckan_version_ref/$python_dockerfile" ]; then
        # Build Python/debian-based image first if there's a separate .pyXX Dockerfile
        # tag image with Python tags only
        DOCKER_BUILDKIT=1 docker build \
            --build-arg="ENV=$env" \
            --build-arg="CKAN_REF=$ckan_tag" \
            -t "$python_tag_name" \
            -t "$python_alt_tag_name" \
            -f "ckan-$ckan_version_ref/$python_dockerfile" \
            "ckan-$ckan_version_ref"
        
        # Now build alpine-based image and use generic tags
        DOCKER_BUILDKIT=1 docker build \
            --build-arg="ENV=$env" \
            --build-arg="CKAN_REF=$ckan_tag" \
            -t "$tag_name" \
            -t "$alt_tag_name" \
            "ckan-$ckan_version_ref"

    else
        # Only build Python/debian-based image and tag with Python plus generic tags
        DOCKER_BUILDKIT=1 docker build \
            --build-arg="ENV=$env" \
            --build-arg="CKAN_REF=$ckan_tag" \
            -t "$tag_name" \
            -t "$alt_tag_name" \
            -t "$python_tag_name" \
            -t "$python_alt_tag_name" \
            "ckan-$ckan_version_ref"
    fi
 
}

show_usage() {
    echo "Usage: $0 <action> [<params>]"
    echo "Available actions:"
    echo "  versions                                - Shows the current CKAN versions used"
    echo "  build <version> [base|dev] [py version] - Builds images for a CKAN version"
    echo "                                            Optionally specify 'base' or 'dev'."
    echo "                                            Optionally specify a Python version."
    echo "  push  <version>                         - Pushes images to the Docker Hub"
    exit 1
}

# Main script logic
if [ $# -eq 0 ]; then
    show_usage
fi

action=$1

case "$action" in
    "versions")
        show_versions
        ;;
    "build")
        ckan_version_ref=$2

        if [ -z "$ckan_version_ref" ]; then
            echo "Missing version"
            show_usage
            exit 1
        fi

        if [ ! -d "ckan-$ckan_version_ref" ]; then
            echo "Unknown version: $ckan_version_ref"
            exit 1
        fi

        # Shift to handle optional arguments more flexibly
        shift 2

        base_or_dev=""
        python_version=""

        # Process remaining arguments
        while [[ $# -gt 0 ]]; do
            case "$1" in
                "base"|"dev")
                    base_or_dev="$1"
                    ;;
                *)
                    # Assume it's a Python version
                    python_version="$1"
                    ;;
            esac
            shift
        done

        # Determine which images to build
        if [ -z "$base_or_dev" ]; then
            build_base=true
            build_dev=true
        else
            case "$base_or_dev" in
                "base")
                    build_base=true
                    ;;
                "dev")
                    build_dev=true
                    ;;
                *)
                    echo "Invalid option: $base_or_dev. Use 'base' or 'dev'."
                    show_usage
                    exit 1
                    ;;
            esac
        fi

        # Build base image if requested
        if [ "$build_base" = true ]; then
            build_images "$ckan_version_ref" "base" "$python_version"
        fi

        # Build dev image if requested
        if [ "$build_dev" = true ]; then
            build_images "$ckan_version_ref" "dev" "$python_version"
        fi
        ;;
    "push")
        ckan_version_ref=$2

        read -p "$check_push_msg" -n 1 -r answer
        echo
        if [[ $answer =~ ^[Yy]$ ]]; then
            push_images "$ckan_version_ref" "base"
            push_images "$ckan_version_ref" "dev"
        fi
        ;;
    *)
        echo "Error: Unknown action '$action'"
        show_usage
        ;;
esac
