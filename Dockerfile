FROM python:slim AS builder

ARG BRANCH="main"
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y git build-essential
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN python -m venv /chia-blockchain/venv
ENV PATH=/chia-blockchain/venv/bin:$PATH

WORKDIR /chia-blockchain/src
RUN git clone --branch $BRANCH https://github.com/Chia-Network/chia-blockchain.git .
RUN git submodule update --init mozilla-ca 
RUN pip install wheel
RUN pip install --extra-index-url https://pypi.chia.net/simple miniupnpc==2.1
RUN pip install --extra-index-url https://pypi.chia.net/simple .


FROM python:slim AS runner

LABEL maintainer="Pakue"
EXPOSE 8555 8444 8447

ENV keys="generate"
ENV harvester="false"
ENV farmer="false"
ENV plots_dir="/plots"
ENV farmer_address="null"
ENV farmer_port="null"
ENV testnet="false"
ENV full_node_port="null"
ENV TZ="UTC"

RUN apt-get update && apt-get install -y tzdata \
    && rm -rf /var/lib/apt/lists/*
ENV PATH=/chia-blockchain/venv/bin:$PATH

COPY --from=builder /chia-blockchain /chia-blockchain

WORKDIR /chia-blockchain
COPY ./entrypoint.sh entrypoint.sh
CMD ["/bin/bash", "./entrypoint.sh"]