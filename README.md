# agent-operator-images

Images for the [agent-operator](https://github.com/Contrast-Security-OSS/agent-operator) project.

Managed by the Contrast .NET agent team.

## Images

Public images are deployed to DockerHub. Currently, this repo publishes:


- [![contrast/agent-dotnet-core](https://img.shields.io/docker/v/contrast/agent-dotnet-core?label=contrast%2Fagent-dotnet-core&logo=docker&logoColor=white&style=flat-square&cacheSeconds=10800)](https://hub.docker.com/r/contrast/agent-dotnet-core)
- [![contrast/agent-dotnet-framework](https://img.shields.io/docker/v/contrast/agent-dotnet-framework?label=contrast%2Fagent-dotnet-framework&logo=docker&logoColor=white&style=flat-square&cacheSeconds=10800)](https://hub.docker.com/r/contrast/agent-dotnet-framework)
- [![contrast/agent-java](https://img.shields.io/docker/v/contrast/agent-java?label=contrast%2Fagent-java&logo=docker&logoColor=white&style=flat-square&cacheSeconds=10800)](https://hub.docker.com/r/contrast/agent-java)
- [![contrast/agent-nodejs](https://img.shields.io/docker/v/contrast/agent-nodejs?label=contrast%2Fagent-nodejs&logo=docker&logoColor=white&style=flat-square&cacheSeconds=10800)](https://hub.docker.com/r/contrast/agent-nodejs)
- [![contrast/agent-php](https://img.shields.io/docker/v/contrast/agent-php?label=contrast%2Fagent-php&logo=docker&logoColor=white&style=flat-square&cacheSeconds=10800)](https://hub.docker.com/r/contrast/agent-php)
- [![contrast/agent-python](https://img.shields.io/docker/v/contrast/agent-python?label=contrast%2Fagent-python&logo=docker&logoColor=white&style=flat-square&cacheSeconds=10800)](https://hub.docker.com/r/contrast/agent-python)


Tags are generated in the following format:

```
:2
:2.1
:2.1.10
:latest
```

## Image layout

All images contain a directory of `/contrast` containing all the agent files. This directory is stable and may be publicly documented.

Inside this directory is a json file `image-manifest.json` with the layout of:

```json
{
    "version": "${VERSION}"
}
```

This file may be used by agents or for debugging containerized deployments in production. Additional information may be added in the future.

Upon starting, the default entrypoint of these images will copy all files from `/contrast` to `$CONTRAST_MOUNT_PATH` (defaults to `/contrast-init`) and exit. Some agents may require a specific `CONTRAST_MOUNT_PATH` to function correctly.

> The .NET Framework agent image does not contain an entrypoint and should only be used to aid in creating base images for Windows Containers. .NET Framework agent files are located in `C:\Contrast`.

## Updating Images

Images are updated by executing a repository dispatch with a provided PAT.

```bash
curl -H "Authorization: token ${GH_PAT}" \
    -H 'Accept: application/vnd.github.everest-preview+json' \
    "https://api.github.com/repos/Contrast-Security-OSS/agent-operator-images/dispatches" \
    -d '{"event_type": "oob-update", "client_payload": {"type": "dotnet-core", "version": "2.1.12"}}'
```

Once the dispatch request is received, the following events execute automatically:

- A PR with the requested version is created on a new branch.
- Basic checks are executed to ensure the version can be built.
- Upon successful validation, the PR is automatically merged into trunk.

Merging into trunk starts the following events:

- Create and publish all images in this repository.
- When all images have been built successfully, start a deployment to `internal`. This copies the artifact images from the first step, with final image tags.
- When the internal environment deployment has succeeded, start a deployment to `public`.

## Creating Backports

Backports may be created by pushing a branch in the format of `backport/<agent name>-v<agent version>` with the version of the agent being backported. Backports will not update the `latest` tag and will not update the Major/Minor tags.
