---
docname: draft-uberti-avtcore-cryptex-00
title: Completely Encrypting RTP Header Extensions and Contributing Sources
category: std
ipr: trust200902
area: ART
workgroup: AVTCORE
keyword: SRTP
stand_alone: yes

pi: [toc, sortrefs, symrefs]

author:
-
    ins: J. Uberti
    name: Justin Uberti
    organization: Google
    email: justin@uberti.name
-
  ins: C. Jennings
  name: Cullen Jennings
  org: Cisco
  email: fluffy@iii.ca

normative:
  RFC2119:
  RFC3711:
  RFC8285:

informative:
  RFC6464:
  RFC6465:
  RFC6904:

--- abstract

While the Secure Real-time Transport Protocol (SRTP) provides confidentiality
for the contents of a media packet, a significant amount of metadata is left
unprotected, including RTP header extensions and contributing sources (CSRCs).
However, this data can be moderately sensitive in many applications. While
there have been previous attempts to protect this data, they have had limited
deployment, due to complexity as well as technical limitations.

This document proposes a new mechanism to completely encrypt header
extensions and CSRCs as well a simpler signaling mechanism intended to
facilitate deployment.

--- middle

Introduction
============

## Problem Statement

The Secure Real-time Transport Protocol [RFC3711] mechanism provides message
authentication for the entire RTP packet, but only encrypts the RTP payload.
This has not historically been a problem, as much of the information carried
in the header has minimal sensitivity (e.g., RTP timestamp); in addition,
certain fields need to remain as cleartext because they are used for key
scheduling (e.g., RTP SSRC and sequence number).

However, as noted in [RFC6904], the security requirements can be different for
information carried in RTP header extensions, including the per-packet sound
levels defined in [RFC6464] and [RFC6465], which are specifically noted as
being sensitive in the Security Considerations section of those RFCs.

In addition to the contents of the header extensions, there are now enough
header extensions in active use that the header extension identifiers
themselves can provide meaningful information in terms of determining the
identity of endpoint and/or application. Accordingly, these identifiers
can be considered at least slightly sensitive.

Finally, the CSRCs included in RTP packets can also be sensitive, potentially
allowing a network eavesdropper to determine who was speaking and when during
an otherwise secure conference call.

## Previous Solutions

[RFC6904] was proposed in 2013 as a solution to the problem of unprotected
header extension values. However, it has not seen significant adoption, and
has a few technical shortcomings.

First, the mechanism is complicated. Since it allows encryption to be
negotiated on a per-extension basis, a fair amount of signaling logic is
required. And in the SRTP layer, a somewhat complex transform is required
to allow only the selected header extension values to be encrypted. One of
the most popular SRTP implementations had a significant bug in this area
that was not detected for five years.

Second, it only protects the header extension values, and not their ids or
lengths. It also does not protect the CSRCs. As noted above, this leaves
a fair amount of potentially sensitive information exposed.

Third, it bloats the header extension space. Because each extension must
be offered in both unencrypted and encrypted forms, twice as many header
extensions must be offered, which will in many cases push implementations
past the 14-extension limit for the use of one-byte extension headers
defined in [RFC8285]. Accordingly, implementations will need to use
two-byte headers in many cases, which are not supported well by some
existing implementations.

Finally, the header extension bloat combined with the need for backwards
compatibility results in additional wire overhead. Because two-byte
extension headers may not be handled well by existing implementations,
one-byte extension identifiers will need to be used for the unencrypted
(backwards compatible) forms, and two-byte for the encrypted forms.
Thus, deployment of [RFC6904] encryption for header extensions will
typically result in multiple extra bytes in each RTP packet, compared
to the present situation.

## Goals

From this analysis we can state the desired properties of a solution:
- Build on existing [RFC3711] SRTP framework (simple to understand)
- Build on existing [RFC8285] header extension framework (simple to implement)
- Protection of header extension ids, lengths, and values
- Protection of CSRCs when present
- Simple signaling
- Simple crypto transform and SRTP interactions
- Backward compatible with unencrypted endpoints, if desired
- Backward compatible with existing RTP tooling

The last point deserves further discussion. While we considered possible
solutions that would have encrypted more of the RTP header (e.g., the number
of CSRCs), we felt the inability to parse the resultant packets with current
tools, as well as additional complexity incurred, outweighed the slight
improvement in confidentiality.

Terminology
===========

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be
interpreted as described in {{RFC2119}}.

Design
======

Signaling
=========

RTP Header Processing
=====================

The processing of header extensions, both in sending and receiving, is
done as specified in [RFC8285] including the usage of the
"extmap-allow-mixed" attribute.

[RFC8285] defines two values for the "defined by profile" field for
carrying one byte and two bytes header extensions. In order to allow a
receiver to differentiate if an incoming RTP packet has header
encryption or not, two new values are defined:

 - 0xC0DE for the encrypted version of the one byte header extensions,
 instead of 0xBEDE.

 - 0xC2Dy for the encrypted versions of the two bytes header extensions,
   instead of 0x100y. The y indicates the 4 bit value of the app bits.


## Sending

When sending an RTP packet that requires any header extensions to a
destination that has negotiated header encryption, the header extensions
MUST be encapsulated inside a {{RFC8285}} header extension.

If one byte codes are in use, the 16 bit RTP header extension tag MUST
be 0xC0DE to indicate that it will be encrypted.  If the two byte header
extension codes are in use, the 16 bit RTP header extension tag MUST be
0xC2Cy to indicate that it will be encrypted where they represents the 4
bits value of the app bits.

The header must by encrypted as described in {{encrypt}}.

## Receiving

After decrypting and authenticating the packet, if there is an RPT
header extension with a 16 bit RTP header extension tag of 0xC0DE or
with the top 24 bits set to 0xC2D, it MUST be decrypted as described in
{{encrypt}} then processed as a normal {{RFC8285}} header extension.

Encryption and Decryption {#encrypt}
===========================

Security Considerations {#security}
=======================

IANA Considerations {#iana}
===================

Acknowledgements
================

Thank you for review and text from Sergio Murillo, Jonathan Lennox, and
Iñaki Castillo.

--- back

