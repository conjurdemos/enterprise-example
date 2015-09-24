#!/usr/bin/env bash

set -x

$(pwd)/populate.exp

conjur group members add --admin operations mindy.fredricks
conjur group members add         operations dave.bartell

conjur group members add --admin hr-admins carlos.vicente
conjur group members add         hr-admins jill.blair

conjur group members add --admin employees russ.reed
conjur group members add         employees jason.knight
conjur group members add         employees jim.harper
conjur group members add         employees cyndi.bruens
conjur group members add         employees barbara.lazar
conjur group members add         employees sam.goodman
conjur group members add         employees jeff.slater
conjur group members add         employees sharon.foster
conjur group members add         employees dick.evans
