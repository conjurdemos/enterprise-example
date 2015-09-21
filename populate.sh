#!/usr/bin/env bash

./populate.exp

conjur group members add --admin operations mindy.fredricks
conjur group members add operations dave.bartell

conjur group members add --admin developers carlos.vicente
conjur group members add developers jill.blair

conjur group members add --admin contractors russ.reed
conjur group members add contractors jason.knight
