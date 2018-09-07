FROM python:2.7 as base
FROM base as builder
RUN mkdir /install
WORKDIR /install
COPY requirements.txt /
RUN pip install --install-option="--prefix=/install" -r /requirements.txt

FROM base
COPY rootfs /
COPY --from=builder /install /usr/local
COPY . /app
WORKDIR /app

ENV POE_COMMIT_ID="${CI_COMMIT_REF_SLUG}"
ENV DOCKER_IMAGE_VERSION="(${POE_COMMIT_ID})"
ENV SLEEP_SPREAD=${SLEEP_SPRREAD:-60}

CMD [ "/startup.sh" ]
