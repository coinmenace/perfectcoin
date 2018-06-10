#!/bin/bash

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
BUILDDIR=${BUILDDIR:-$TOPDIR}

BINDIR=${BINDIR:-$BUILDDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

PERFECTCOIND=${PERFECTCOIND:-$BINDIR/perfectcoind}
PERFECTCOINCLI=${PERFECTCOINCLI:-$BINDIR/perfectcoin-cli}
PERFECTCOINTX=${PERFECTCOINTX:-$BINDIR/perfectcoin-tx}
PERFECTCOINQT=${PERFECTCOINQT:-$BINDIR/qt/bitcoin-qt}

[ ! -x $PERFECTCOIND ] && echo "$PERFECTCOIND not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
PTCVER=($($PERFECTCOINCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for perfectcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and perfectcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$PERFECTCOIND --version | sed -n '1!p' >> footer.h2m

for cmd in $PERFECTCOIND $PERFECTCOINCLI $PERFECTCOINTX $PERFECTCOINQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${PTCVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${PTCVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
