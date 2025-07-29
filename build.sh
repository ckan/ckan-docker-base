#!/bin/bash
set -e

check_push_msg="Are you sure you want to push these images? (y/N): "

log() {
    echo "[INFO] $1"
}

show_versions() {
    echo "Available CKAN versions:"
    count=1

    # Collect all directories matching the pattern "ckan-*"
    versions=()
    for dir in ckan-*; do
        if [ -f "$dir/VERSION.txt" ]; then
            patchversion=$(<"$dir/VERSION.txt")
            versions+=("$patchversion")
        fi
    done

    # Sort versions: master first, then descending numerical order
    sorted_versions=$(printf "%s\n" "${versions[@]}" | sort -rV | sed '/^master$/d')
    sorted_versions="master"$'\n'"$sorted_versions"

    # Display sorted versions
    for version in $sorted_versions; do
        minorversion="${version%.*}"
        echo "$count. $minorversion (patch version: $version)"
        ((count++))
    done
}

show_tags() {
    echo "Available CKAN tags:"

    # Collect all directories matching the pattern "ckan-*"
    versions=()
    for dir in ckan-*; do
        if [ -f "$dir/VERSION.txt" ]; then
            patchversion=$(<"$dir/VERSION.txt")
            versions+=("$patchversion")
        fi
    done

    # Sort versions: master first, then descending numerical order
    sorted_versions=$(printf "%s\n" "${versions[@]}" | sort -rV | sed '/^master$/d')
    sorted_versions="master"$'\n'"$sorted_versions"

    # Process sorted versions
    last_git_tag=$(git describe --tags --abbrev=0)
    last_minor_version=""
    for version in $sorted_versions; do
        if [[ "$version" == "master" ]]; then
            # Special case for master
            python_version=$(cat "ckan-master/PYTHON_VERSION.txt")
            echo "Tags for CKAN version master:"
            echo "  - master"
            echo "  - master-py$python_version"
            echo "  - master-py$python_version-$last_git_tag"
        else
            # Handle regular versions
            minor_version="${version%.*}" # Extract the minor version (e.g., 2.11)
            python_version=$(cat "ckan-$minor_version/PYTHON_VERSION.txt")

            echo "Tags for CKAN version $minor_version (patch version: $version):"
            # Print minor version tag only once
            if [[ "$minor_version" != "$last_minor_version" ]]; then
                echo "  - $minor_version"
                echo "  - $minor_version-$last_git_tag"
                echo "  - $minor_version-py$python_version"
                echo "  - $minor_version-py$python_version-$last_git_tag"
            fi
            # Print full version tag
            echo "  - $version"
            echo "  - $version-$last_git_tag"
            echo "  - $version-py$python_version"
            echo "  - $version-py$python_version-$last_git_tag"
            last_minor_version="$minor_version"
        fi
        echo ""
    done
}

push_images() {
    local ckan_version_ref="$1"
    local env="$2"
    set_vars "$ckan_version_ref" "$env"

    log "Pushing image: $tag_name"
    docker push "$tag_name"
    docker push "$alt_tag_name"
    
    # Check if a Python Dockerfile exists
    if [[ -n "$python_dockerfile" ]]; then
        log "Pushing image: $python_tag_name"
        docker push "$python_tag_name"
        docker push "$python_alt_tag_name"
    
    # If not, check if the CKAN version is greater than 2.10
    elif [[ "$ckan_version_ref" =~ ^([2-9])\.([0-9]+) ]]; then
        major=${BASH_REMATCH[1]}
        minor=${BASH_REMATCH[2]}
    
    # Check if major version is greater than 2 or if it's 2 and minor is greater than 10
    if [[ $major -gt 2 || ($major -eq 2 && $minor -gt 10) ]]; then
        log "Pushing image: $python_tag_name"
        docker push "$python_tag_name"
        docker push "$python_alt_tag_name"
    fi
fi
}

set_vars() {
    local ckan_version_ref="$1"
    local env="$2"
    local python_version="$3"

    if [ ! -d "ckan-$ckan_version_ref" ]; then
    echo "Unknown version: $ckan_version_ref"
    exit 1
    fi

    ckan_version=$(cat "ckan-$ckan_version_ref/VERSION.txt")
    if [ -z "$python_version" ]; then
        PYTHON_VERSION=$(cat "ckan-$ckan_version_ref/PYTHON_VERSION.txt")
    else
        PYTHON_VERSION="$python_version"
    fi

    pattern="Dockerfile.py*"
    dir="ckan-$ckan_version_ref"
    matches=("$dir"/$pattern)

    if [ -e "${matches[0]}" ]; then
        python_dockerfile_incl_path="${matches[0]}"
        python_dockerfile=$(basename "$python_dockerfile_incl_path")
        log "Python Dockerfile found: $python_dockerfile"
    else
        log "No Python Dockerfile found."
    fi

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

    if compgen -G "ckan-$ckan_version_ref/Dockerfile.py*" > /dev/null; then
        log "1/2 Building $ckan_version_ref Python-based image"
        DOCKER_BUILDKIT=1 docker build \
            --build-arg="ENV=$env" \
            --build-arg="CKAN_REF=$ckan_tag" \
            --build-arg="PYTHON_VERSION=$PYTHON_VERSION" \
            -t "$python_tag_name" \
            -t "$python_alt_tag_name" \
            -f "ckan-$ckan_version_ref/$python_dockerfile" \
            "ckan-$ckan_version_ref"

        log "2/2 Building $ckan_version_ref alpine-based image"
        DOCKER_BUILDKIT=1 docker build \
            --build-arg="ENV=$env" \
            --build-arg="CKAN_REF=$ckan_tag" \
            --build-arg="PYTHON_VERSION=$PYTHON_VERSION" \
            -t "$tag_name" \
            -t "$alt_tag_name" \
            "ckan-$ckan_version_ref"
    else
        log "1/1 Building $ckan_version_ref Python-based image"
        DOCKER_BUILDKIT=1 docker build \
            --build-arg="ENV=$env" \
            --build-arg="CKAN_REF=$ckan_tag" \
            --build-arg="PYTHON_VERSION=$PYTHON_VERSION" \
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
    echo "  tags                                    - Shows all tags for all CKAN versions"
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
    "tags")
        show_tags
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

        shift 2

        base_or_dev=""
        python_version=""

        while [[ $# -gt 0 ]]; do
            case "$1" in
                "base"|"dev")
                    base_or_dev="$1"
                    ;;
                *)
                    python_version="$1"
                    ;;
            esac
            shift
        done

        if [ -z "$base_or_dev" ]; then
            build_base=true
            build_dev=true
        else
            case "$base_or_dev" in
                "base") build_base=true ;;
                "dev")  build_dev=true  ;;
                *)
                    echo "Invalid option: $base_or_dev. Use 'base' or 'dev'."
                    show_usage
                    exit 1
                    ;;
            esac
        fi

        if [ "$build_base" = true ]; then
            build_images "$ckan_version_ref" "base" "$python_version"
        fi

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

