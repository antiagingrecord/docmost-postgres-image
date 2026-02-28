# ---- build stage ----
FROM postgres:16-alpine AS build
RUN apk add --no-cache build-base git postgresql16-dev clang19 llvm19
WORKDIR /build
ARG PGBIGM_REF=v1.2-20240606
RUN git clone --depth 1 --branch "${PGBIGM_REF}" https://github.com/pgbigm/pg_bigm.git
WORKDIR /build/pg_bigm
RUN make USE_PGXS=1 && make USE_PGXS=1 install

# ---- runtime stage ----
FROM postgres:16-alpine
# 必要な成果物だけコピー
COPY --from=build /usr/local/lib/postgresql/pg_bigm.so \
                  /usr/local/lib/postgresql/pg_bigm.so
COPY --from=build /usr/local/share/postgresql/extension/pg_bigm.control \
                  /usr/local/share/postgresql/extension/pg_bigm.control
COPY --from=build /usr/local/share/postgresql/extension/pg_bigm--*.sql \
                  /usr/local/share/postgresql/extension/