#!/bin/sh

# SPDX-FileCopyrightText: 2019 Omar Roth <omarroth@protonmail.com>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

psql invidious kemal -c "ALTER TABLE channels ADD COLUMN deleted bool;"
psql invidious kemal -c "UPDATE channels SET deleted = false;"
