# Development environment setup

This subsection describes how to build the development environment image for this project.

## Get the Dockerfile

Download the [Dockerfile](https://github.com/teratide/fletcher-opae/blob/master/Dockerfile) or clone the [repository](https://github.com/teratide/fletcher-opae).

```
git clone https://github.com/teratide/fletcher-opae
cd fletcher-opae/
```

## Build the image.

```
docker build -t ias:1.2.1 - < Dockerfile
```

That's it.
