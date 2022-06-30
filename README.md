# agent-operator-images

Images for the [agent-operator](https://github.com/Contrast-Security-OSS/agent-operator) project.

Managed by the Contrast .NET agent team.

## Images

Public images are deployed to DockerHub. Currently, this repo publishes:


[![contrast/agent-dotnet-core](https://img.shields.io/docker/v/contrast/agent-dotnet-core?label=contrast%2Fagent-dotnet-core&logo=docker&logoColor=white&style=flat-square&cacheSeconds=86400)](https://hub.docker.com/repository/docker/contrast/agent-dotnet-core)
[![contrast/agent-java](https://img.shields.io/docker/v/contrast/agent-java?label=contrast%2Fagent-java&logo=docker&logoColor=white&style=flat-square&cacheSeconds=86400)](https://hub.docker.com/repository/docker/contrast/agent-java)
[![contrast/agent-nodejs](https://img.shields.io/docker/v/contrast/agent-nodejs?label=contrast%2Fagent-nodejs&logo=docker&logoColor=white&style=flat-square&cacheSeconds=86400)](https://hub.docker.com/repository/docker/contrast/agent-nodejs)
[![contrast/agent-php](https://img.shields.io/docker/v/contrast/agent-php?label=contrast%2Fagent-php&logo=docker&logoColor=white&style=flat-square&cacheSeconds=86400)](https://hub.docker.com/repository/docker/contrast/agent-php)


Tags are generated in the following format for agents that support semantic versioning. For the Java agent, the format is similar.

```
:2
:2.1
:2.1.10
:latest
```

## Image layout

All images contain a directory of `/contrast` containing all the agent files. This directory is stable and may be publicly documented.

Inside this directory is a json file `/contrast/image-manifest.json` with the layout of:

```json
{
    "version": "${VERSION}"
}
```

This file may be used by agents or for debugging containerized deployments in production. Additional information may be added in the future.

Upon starting, the default entrypoint of these images will copy all files from `/contrast` to `$CONTRAST_MOUNT_PATH` (defaults to `/contrast-init`) and exit. Some agents may require a specific `CONTRAST_MOUNT_PATH` to function correctly.

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
