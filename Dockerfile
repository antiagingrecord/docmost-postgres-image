# ---- build stage ----
FROM postgres:18-alpine AS build

# postgresql18-dev は入れない（imageに既に /usr/local/bin/pg_config がある）
# clang/llvm はバージョン固定しない（Alpine 3.22 の提供バージョンに合わせる）
RUN apk add --no-cache build-base git clang llvm

WORKDIR /build
ARG PGBIGM_REF=v1.2-20250903
RUN git clone --depth 1 --branch "${PGBIGM_REF}" https://github.com/pgbigm/pg_bigm.git
WORKDIR /build/pg_bigm
RUN make USE_PGXS=1 && make USE_PGXS=1 install

# ---- runtime stage ----
FROM postgres:18-alpine
COPY --from=build /usr/local/lib/postgresql/pg_bigm.so \
                  /usr/local/lib/postgresql/pg_bigm.so
COPY --from=build /usr/local/share/postgresql/extension/pg_bigm.control \
                  /usr/local/share/postgresql/extension/pg_bigm.control
COPY --from=build /usr/local/share/postgresql/extension/pg_bigm--*.sql \
                  /usr/local/share/postgresql/extension/

