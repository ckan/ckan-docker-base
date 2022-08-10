To install Container Canary do the following:

curl -L https://github.com/NVIDIA/container-canary/releases/download/v0.2.1/canary_darwin_amd64 > /path/to/ContainerCanary/canary_darwin_amd64
curl -L https://github.com/NVIDIA/container-canary/releases/download/v0.2.1/canary_darwin_amd64.sha256sum > /path/to/ContainerCanary/canary_darwin_amd64.sha256sum

cd /path/to/ContainerCanary

shasum -a 256 --check --status canary_darwin_amd64.sha256sum
chmod +x canary_darwin_amd64
cp canary_darwin_amd64 /usr/local/bin/canary

/usr/local/bin/canary version

Should show something like this:
Container Canary
 Version:         v0.2.1
 Go Version:      go1.17.8
 Commit:          d97ec23
 OS/Arch:         darwin/amd64
 Built:           2022-04-14T10:03:44Z

Create a file used for validation (call it ckan.yaml)

Run the following:
canary validate --file ckan.yaml ckan/ckan-base:2.9.5

Make sure a CKAN container using the same port as ckan/ckan-base:2.9.5 is not running before starting the validation