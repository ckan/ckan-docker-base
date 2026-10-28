#!/bin/bash
set -e

# Need a custom platform and can't wait for the official image, use this script to build it locally
# Docker
# ./build.sh build 2.12 dev
# OR
# Podman
# ./build.sh --podman build 2.12 dev
#
# example usage where private register and different namespace prefix is needed
# This will create and push registry.abc.xyz.com/custom-$REGISTRY/$NAMESPACE/ckan-base:2.12
# DOCKER
# docker login registry.abc.xyz.com
# ./build.sh --registry registry.abc.xyz.com --namespace custom-ckan push 2.12
#
# PODMAN
# https://docs.podman.io/en/latest/markdown/podman-manifest-push.1.html?#authfile-path
# podman login registry.abc.xyz.com
# ./build.sh --podman --registry registry.abc.xyz.com --namespace custom-ckan push 2.12
#
# Environment variables for clean build scripts also works
# export CONTAINER_ENGINE=podman
# export REGISTRY=registry.abc.xyz.com
# export NAMESPACE=custom-ckan
# ./build.sh push 2.11
# ./build.sh push 2.12
# etc

check_push_msg="Are you sure you want to build and push multi-arch images? (y/N): "

# Docker defaults
CONTAINER_ENGINE="${CONTAINER_ENGINE:-docker}"
REGISTRY="${REGISTRY:-docker.io}"
NAMESPACE="${NAMESPACE:-ckan}"

log() {
    echo "[INFO] $1"
}

show_versions() {
    echo "Available CKAN versions:"
    count=1
    for dir in ckan-*; do
        if [ -f "$dir/VERSION.txt" ]; then
            patchversion=$(<"$dir/VERSION.txt")
            minorversion="${patchversion%.*}"
            echo "$count. $minorversion (patch version: $patchversion)"
            ((count++))
        fi
    done
}

push_images() {
    local ckan_version_ref="$1"
    local env="$2"

    log "Pushing image: $tag_name"
    # We call build_images with specific platforms and the --push flag
    build_images "$ckan_version_ref" "$env" "" "linux/amd64,linux/arm64" "--push"
}

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

    pattern="Dockerfile.py*"
    dir="ckan-$ckan_version_ref"
    matches=("$dir"/$pattern)

    if [ -e "${matches[0]}" ]; then
        python_dockerfile_incl_path="${matches[0]}"
        python_dockerfile=$(basename "$python_dockerfile_incl_path")
        log "Python Dockerfile found: $python_dockerfile"
    else
        log "No Python Dockerfile found."
        python_dockerfile=""
    fi

    tag_name="$REGISTRY/$NAMESPACE/ckan-$env:$ckan_version"
    python_tag_name="$REGISTRY/$NAMESPACE/ckan-$env:$ckan_version-py$PYTHON_VERSION"
    if [[ "$ckan_version" == "master" || "$ckan_version" == dev* ]]; then
        ckan_tag=$ckan_version
        alt_tag_name=$tag_name
        python_alt_tag_name=$python_tag_name
    else
        ckan_tag=ckan-$ckan_version
        ckan_version_major=$(echo "$ckan_version" | cut -d'.' -f1)
        ckan_version_minor=$(echo "$ckan_version" | cut -d'.' -f2)
        alt_tag_name="$REGISTRY/$NAMESPACE/ckan-$env:$ckan_version_major.$ckan_version_minor"
        python_alt_tag_name="$REGISTRY/$NAMESPACE/ckan-$env:$ckan_version_major.$ckan_version_minor-py$PYTHON_VERSION"
    fi
}

build_images() {
    local ckan_version_ref="$1"
    local env="$2"
    local python_version="$3"
    local platforms="$4"   # "linux/amd64,linux/arm64"
    local push_flag="$5"   # "--push"

    set_vars "$ckan_version_ref" "$env" "$python_version"

    local -a build_opts=()
    local -a tags=()

    if [ -n "$platforms" ]; then
        build_opts+=(--platform "$platforms")
    fi

    if [ "$CONTAINER_ENGINE" = "docker" ]; then
        build_opts+=(--push)
    elif [ -n "$push_flag" ]; then
        # Podman publishes manifests separately after building.
        :
    fi

    run_build() {
        local manifest="$1"
        shift
        local -a args=("$@")
        local -a tags=()
        local -a build_args=()
        local arg tag arch staging_tag
        local i

        # Extract image tags and keep the remaining build arguments.
        while (($#)); do
            arg="$1"
            shift

            if [[ "$arg" == "-t" ]]; then
                (($#)) || {
                    echo "[ERROR] Missing value after -t" >&2
                    return 1
                }
                tags+=("$1")
                shift
            else
                build_args+=("$arg")
            fi
        done


        if [ "$CONTAINER_ENGINE" = "docker" ]; then
            docker buildx build "${build_opts[@]}" "${args[@]}" "${build_args[@]}"
            return
        fi

        if [ -z "$push_flag" ]; then
          #local build (not push)
          podman build "${build_opts[@]}" "${build_args[@]}" "${tags[@]/#/-t}"
          return
        fi

        #Not Docker, Not local, handle Podman's per arch build and push all manifest
        local -a staging_tags=()

        for arch in amd64 arm64; do
            staging_tag="${manifest}-${arch}"
            staging_tags+=("$staging_tag")

            log "Building and pushing $staging_tag"
            podman build --platform "linux/$arch" "${build_args[@]}" -t "$staging_tag"
            podman push "$staging_tag"
        done

        # now assemble the remote architecture images into a manifest listing.
        podman manifest rm "$manifest" >/dev/null 2>&1 || true
        podman manifest create "$manifest"

        for staging_tag in "${staging_tags[@]}"; do
            podman manifest add \
                "$manifest" \
                "docker://$staging_tag"
        done

        # Publish every release tag as a multi-architecture manifest.
        for tag in "${tags[@]}"; do
            log "Pushing multi-architecture manifest: $tag"
            podman manifest push --all "$manifest" "docker://$tag"
        done

        #cleanup
        podman manifest rm "$manifest"

    }

    if compgen -G "ckan-$ckan_version_ref/Dockerfile.py*" > /dev/null; then
        log "Building $ckan_version_ref Python-based image ($platforms)"
        run_build "$tag_name" \
            --build-arg="ENV=$env" \
            --build-arg="CKAN_REF=$ckan_tag" \
            --build-arg="PYTHON_VERSION=$PYTHON_VERSION" \
            -t "$python_tag_name" \
            -t "$python_alt_tag_name" \
            -f "ckan-$ckan_version_ref/$python_dockerfile" \
            "ckan-$ckan_version_ref"

        log "Building $ckan_version_ref alpine-based image ($platforms)"
        run_build "$tag_name" \
            --build-arg="ENV=$env" \
            --build-arg="CKAN_REF=$ckan_tag" \
            --build-arg="PYTHON_VERSION=$PYTHON_VERSION" \
            -t "$tag_name" \
            -t "$alt_tag_name" \
            "ckan-$ckan_version_ref"
    else
        log "Building $ckan_version_ref images ($platforms)"
        run_build "$tag_name" \
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
    echo "Usage: $0 [--podman | --engine docker|podman] [--registry custom-registry] [--namespace custom-ckan] <action> [<params>]"
    echo "Available actions:"
    echo "  versions                                - Shows the current CKAN versions used"
    echo "  build <version> [base|dev] [py version] - Builds images (local architecture) for a version"
    echo "  push  <version>                         - Builds and pushes multi-arch images (amd64, arm64)"
    exit 1
}

# Main script logic
if [ $# -eq 0 ]; then
    show_usage
fi

# Parse optional flags before the action.
while [[ $# -gt 0 ]]; do
    case "$1" in
        --podman)
            CONTAINER_ENGINE="podman"
            shift
            ;;
        --engine)
            [ $# -ge 2 ] || show_usage
            case "$2" in
                docker|podman) CONTAINER_ENGINE="$2" ;;
                *) echo "Invalid container engine: $2"; show_usage ;;
            esac
            shift 2
            ;;
        --registry)
            [ $# -ge 2 ] || show_usage
            REGISTRY="$2"
            shift 2
            ;;
        --namespace)
            [ $# -ge 2 ] || show_usage
            NAMESPACE="$2"
            shift 2
            ;;
        --)
            shift
            break
            ;;
        -*)
            echo "Unknown option: $1"
            show_usage
            ;;
        *)
            break
            ;;
    esac
done

# Recheck after removing optional args
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
        if [ -z "$ckan_version_ref" ]; then
            echo "Missing version"
            show_usage
            exit 1
        fi
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

