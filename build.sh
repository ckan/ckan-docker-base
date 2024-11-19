#!/bin/bash

set -e


set_vars() {
    local ckan_version_ref="$1"
    local env="$2"

    ckan_version=$(cat "ckan-$ckan_version_ref/VERSION.txt")
    python_version=$(cat "ckan-$ckan_version_ref/PYTHON_VERSION.txt")
    python_dockerfile=Dockerfile.py$python_version
    tag_name="ckan/ckan-$env:$ckan_version"
    python_tag_name="ckan/ckan-$env:$ckan_version-py$python_version"
    if [ "$ckan_version" = "master" ]; then
        ckan_tag=$ckan_version
        alt_tag_name=$tag_name
        python_alt_tag_name=$python_tag_name
    else
        ckan_tag=ckan-$ckan_version
        ckan_version_major=$(echo "$ckan_version" | cut -d'.' -f1)
        ckan_version_minor=$(echo "$ckan_version" | cut -d'.' -f2)
        alt_tag_name="ckan/ckan-$env:$ckan_version_major.$ckan_version_minor"
        python_alt_tag_name="ckan/ckan-$env:$ckan_version_major.$ckan_version_minor-py$python_version"
    fi

}


build_images() {
    local ckan_version_ref="$1"
    local env="$2"

    set_vars "$ckan_version_ref" "$env"

    if [ -f "ckan-$ckan_version_ref/$python_dockerfile" ]; then
        # Build Python image if there's a separate .pyXX Dockerfile
        DOCKER_BUILDKIT=1 docker build \
            --build-arg="ENV=$env" \
            --build-arg="CKAN_REF=$ckan_tag" \
            -t "$python_tag_name" \
            -t "$python_alt_tag_name" \
            -f "ckan-$ckan_version_ref/$python_dockerfile" \
            "ckan-$ckan_version_ref"
    fi

    # Build image 
    DOCKER_BUILDKIT=1 docker build \
        --build-arg="ENV=$env" \
        --build-arg="CKAN_REF=$ckan_tag" \
         -t "$tag_name" \
         -t "$alt_tag_name" \
         -t "$python_tag_name" \
         -t "$python_alt_tag_name" \
         "ckan-$ckan_version_ref"
}


push_images() {
    local ckan_version_ref="$1"
    local env="$2"

    set_vars "$ckan_version_ref" "$env"
    
    echo "Pushing $tag_name"
    docker push "$tag_name"
    echo "Pushing $alt_tag_name"
    docker push "$alt_tag_name"
    echo "Pushing $python_tag_name"
    docker push "$python_tag_name"
    echo "Pushing $python_alt_tag_name"
    docker push "$python_alt_tag_name"

}


show_versions() {
    echo "Versions built currently:"
    cat ckan-*/VERSION.txt | sort -t. -k1,1n -k2,2n | sed 's/^/* /'
}


show_usage() {
    echo "Usage: $0 <action> [<params>]"
    echo "Available actions:"
    echo "  versions                   - Shows the current CKAN versions used"
    echo "  build <version> [base|dev] - Builds images for a CKAN version"
    echo "                               Pass 'base' or 'dev' to just build these."
    echo "  push  <version>            - Pushes images to the Docker Hub"
    exit 1
}

check_push_msg="
**********************************************************************
*                                                                    *
* Warning: Pushing images to the Docker Hub should generally be done *
* via automated GitHub Actions.                                      *
*                                                                    *
**********************************************************************

Are you sure you want to proceed? [y/N]"


# Check if at least one parameter is provided
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

        base_or_dev=$3

        case "$base_or_dev" in
            "base")
                build_base=true
                ;;
            "dev")
                build_dev=true
                ;;
            "")
                build_base=true
                build_dev=true
                ;;
            *)
                echo "Please enter 'base' or 'dev'"
                show_usage
                exit 1
        esac

        if [ "$build_base" = true ]; then
            build_images "$ckan_version_ref" "base"
        fi
        if [ "$build_dev" = true ]; then
            build_images "$ckan_version_ref" "dev"
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
