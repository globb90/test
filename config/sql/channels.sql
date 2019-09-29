--SPDX-FileCopyrightText: 2019 Omar Roth <omarroth@protonmail.com>
--SPDX-License-Identifier: AGPL-3.0-or-later

-- Table: public.channels

-- DROP TABLE public.channels;

CREATE TABLE public.channels
(
  id text NOT NULL,
  author text,
  updated timestamp with time zone,
  deleted boolean,
  subscribed timestamp with time zone,
  CONSTRAINT channels_id_key UNIQUE (id)
);

GRANT ALL ON TABLE public.channels TO kemal;

-- Index: public.channels_id_idx

-- DROP INDEX public.channels_id_idx;

CREATE INDEX channels_id_idx
  ON public.channels
  USING btree
  (id COLLATE pg_catalog."default");

