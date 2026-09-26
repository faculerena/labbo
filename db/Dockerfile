FROM mysql:8

# SQL updates from the same Arcturus commit the emulator image is built from
ARG SQL_URL=https://git.mc8051.de/nitro/Arcturus-Community/raw/commit/3bb8ce162459fc72cedd480cc63cc70fefd7c3d4/sqlupdates

# Runs once, in name order, on an empty data volume
COPY 01-base.sql /docker-entrypoint-initdb.d/
ADD "${SQL_URL}/3_0_0%20to%203_5_0.sql" /docker-entrypoint-initdb.d/02-3_0_0-to-3_5_0.sql
ADD "${SQL_URL}/3_5_0%20to%204_0_0.sql" /docker-entrypoint-initdb.d/03-3_5_0-to-4_0_0.sql
ADD "${SQL_URL}/4_0_0_pets_EN.sql" /docker-entrypoint-initdb.d/04-pets_EN.sql
ADD "${SQL_URL}/4_0_0_permissions.sql" /docker-entrypoint-initdb.d/05-permissions.sql
COPY 06-perms_groups.sql 99-settings.sh /docker-entrypoint-initdb.d/
# upstream SQL quirks the mysql CLI rejects: "--comment" without space, hardcoded `aurora` schema
RUN sed -i -e 's/^--\([^ -]\)/-- \1/' -e 's/`aurora`\.//g' /docker-entrypoint-initdb.d/*.sql && chmod 644 /docker-entrypoint-initdb.d/*
