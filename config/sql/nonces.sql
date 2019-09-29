--SPDX-FileCopyrightText: 2019 Omar Roth <omarroth@protonmail.com>
--SPDX-License-Identifier: AGPL-3.0-or-later

-- Table: public.nonces

-- DROP TABLE public.nonces;

CREATE TABLE public.nonces
(
  nonce text,
  expire timestamp with time zone,
  CONSTRAINT nonces_id_key UNIQUE (nonce)
);

GRANT ALL ON TABLE public.nonces TO kemal;

-- Index: public.nonces_nonce_idx

-- DROP INDEX public.nonces_nonce_idx;

CREATE INDEX nonces_nonce_idx
  ON public.nonces
  USING btree
  (nonce COLLATE pg_catalog."default");

