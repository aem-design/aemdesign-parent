AEM Design Parent
=================

[![build_status](https://github.com/aem-design/aemdesign-parent/workflows/ci/badge.svg)](https://github.com/aem-design/aemdesign-parent/actions?workflow=ci)
[![github license](https://img.shields.io/github/license/aem-design/aemdesign-parent)](https://github.com/aem-design/aemdesign-parent) 
[![github issues](https://img.shields.io/github/issues/aem-design/aemdesign-parent)](https://github.com/aem-design/aemdesign-parent) 
[![github last commit](https://img.shields.io/github/last-commit/aem-design/aemdesign-parent)](https://github.com/aem-design/aemdesign-parent) 
[![github repo size](https://img.shields.io/github/repo-size/aem-design/aemdesign-parent)](https://github.com/aem-design/aemdesign-parent) 
[![github repo size](https://img.shields.io/github/languages/code-size/aem-design/aemdesign-parent)](https://github.com/aem-design/aemdesign-parent)
[![Visit AEM.Design](https://img.shields.io/badge/visit-aem.design-brightgreen)](https://aem.design/)
[![Gitter](https://img.shields.io/gitter/room/aem-design/Lobby)](https://gitter.im/aem-design/Lobby)


## Prerequisites

You need:

1. Docker
2. Java 8 or 11.

## Developer Setup

1. For best experience see [Developer Setup](docs/SETUP.md)
2. Clone parent repo

```bash
git clone --recursive git@github.com:aem-design/aemdesign-parent.git
```

3. Start AEM Stack

```bash
docker-compose up
```

4. Deploy Core and Support

```bash
docker-compose up author-deploy-core author-deploy-support
```

5. Open `http://localhost` and access Services :D

# Repos Info

Following is a description of each repo and their purpose.

For more information see [Project Artifacts](http://aem.design/manifesto/project/#project-artifacts)

| Repo                            | Notes                                       |
|---------------------------------|---------------------------------------------|
| aemdesign-parent/               | root repo for devops script and automation  |
| aemdesign-aem-core/             | primary repo for aemdesign code artifacts   |
| aemdesign-aem-support/          | repo with reference implementation          |
| aemdesign-operations/           | operations and deployment projects          |
| aemdesign-archetype/            | archetype project for new projects          |

## Container Logs

You can monitor logs of containers by either using Docker container logs interface or manually using docker:

```bash
docker logs -f aemdesign-parent_author_1
```

If your container is not configured to output all log to console then you can use the exec to tail the logs directly

```bash
docker exec -it aemdesign-parent_author_1 tail -f crx-quickstart/logs/error.log
```

Tail container log from a specific date

```bash
docker logs -ft aemdesign-parent_author_1 --since 2019-01-18
```

You can remove container logs like this

```powershell
docker run --rm -v /var/lib/docker:/var/lib/docker alpine sh -c "echo '' > $(docker inspect --format='{{.LogPath}}' aemdesign-parent_author_1)"
```
