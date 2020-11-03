---
docname: draft-uberti-avtcore-cryptex-01
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
  RFC4566:
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

This specification proposes a mechanism to negotiate encryption of all
RTP header extensions (ids, lengths, and values) as well as CSRC values. It
reuses the existing SRTP framework, is accordingly simple to implement, and
is backward compatible with existing RTP packet parsing code, even when
support for this mechanism has been negotiated.

Signaling
=========

In order to determine whether this mechanism defined in this specification
is supported, this document defines a new "a=extmap-encrypted"
Session Description Protocol (SDP) {{RFC4566}} attribute to indicate support.
This attribute takes no value, and
can be used at the session level or media level. Offering this attribute
indicates that the endpoint is capable of receiving RTP packets encrypted
as defined below.

   The formal definition of this attribute is:

      Name: extmap-encrypted

      Value: None

      Usage Level: session, media

      Charset Dependent: No

      Example:

         a=extmap-encrypted

   When used with BUNDLE, this attribute is specified as the
   TRANSPORT category. (todo: REF)

RTP Header Processing
=====================
{{RFC8285}} defines two values for the "defined by profile" field for carrying
one-byte and two-byte header extensions. In order to allow a receiver to determine
if an incoming RTP packet is using the encryption scheme in this specification,
two new values are defined:

 - 0xC0DE for the encrypted version of the one-byte header extensions (instead of 0xBEDE).
 - 0xC2DE for the encrypted versions of the two-byte header extensions (instead of 0x100).

In the case of using two-byte header extensions, the extension id with value 256 MUST NOT
be negotiated, as the value of this id is meant to be contained in the "appbits" of the
"defined by profile" field, which are not available when using the values above.

If the "a=extmap-allow-mixed" attribute defined in {{RFC8285}} is negotiated, either one-byte
or two-byte header ids can be used (with the values above), as in {{RFC8285}}.

## Sending

When sending an RTP packet that requires any header extensions to a
destination that has negotiated header encryption, the header extensions
MUST be formatted as {{RFC8285}} header extensions, as usual.

If one-byte extension ids are in use, the 16-bit RTP header extension tag MUST
be set to 0xC0DE to indicate that the encryption defined in this specification
has been applied. If two-byte header extension codes are in use, the 16-bit RTP
header extension tag MUST be set to 0xC2DE to indicate the same.

The RTP packet MUST then be encrypted as described in Encryption Procedure.

## Receiving

When receiving an RTP packet that contains header extensions, the
"defined by profile" field MUST be checked to ensure the payload is
formatted according to this specification. If the field does not match
one of the values defined above, the implementation MUST instead
handle it according to the specification that defines that value.
The implemntation MAY stop and report an error if it considers use of
this specification mandatory for the RTP stream.

If the RTP packet passes this check, it is then decrypted according to
Decryption Procedure, and passed to the the next layer to process
the packet and its extensions.

Encryption and Decryption
=========================

## Packet Structure

When this mechanism is active, the SRTP packet is protected as follows:

          0                   1                   2                   3
        0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+<+
       |V=2|P|X|  CC   |M|     PT      |       sequence number         | |
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ |
       |                           timestamp                           | |
       +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ |
       |           synchronization source (SSRC) identifier            | |
     +>+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+ |
     | |            contributing source (CSRC) identifiers             | |
     | |                               ....                            | |
     +>+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ |
     X |       0xC0    |    0xDE       |           length=3            | |
     +>+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ |
     | |                  RFC 8285 header extensions                   | |
     | +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ |
     | |                          payload  ...                         | |
     | |                               +-------------------------------+ |
     | |                               | RTP padding   | RTP pad count | |
     +>+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+<+
     | ~                     SRTP MKI (OPTIONAL)                       ~ |
     | +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ |
     | :                 authentication tag (RECOMMENDED)              : |
     | +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+ |
     |                                                                   |
     +- Encrypted Portions*                     Authenticated Portion ---+

* Note that the 4 bytes at the start of the extension block are not encrypted, as
required by {{RFC8285}}.

Specifically, the encrypted portion MUST include any CSRC identifiers, any
RTP header extension (except for the first 4 bytes), and the RTP payload.

## Encryption Procedure

The encryption procedure is identical to that of {{RFC3711}} except for the
region to encrypt, which is as shown in the section above.

To minimize changes to surrounding code, the encryption mechanism can choose
to replace a "defined by profile" field from {{RFC8285}} with its counterpart
defined in RTP Header Processing above and encrypt at the same time.

## Decryption Procedure

The decryption procedure is identical to that of {{RFC3711}} except
for the region to decrypt, which is as shown in the section above.

To minimize changes to surrounding code, the decryption mechanism can choose
to replace the "defined by profile" field with its no-encryption counterpart
from {{RFC8285}} and decrypt at the same time.

Backwards Compatibility
=======================

This specification attempts to encrypt as much as possible without interfering
with backwards compatibility for systems that expect a certain structure from
an RTPv2 packet, including systems that perform demultiplexing based on packet
headers. Accordingly, the first two bytes of the RTP packet are not encrypted.

This specification also attempts to reuse the key scheduling from SRTP, which
depends on the RTP packet sequence number and SSRC identifier. Accordingly
these values are also not encrypted.

Security Considerations
=======================

This specification extends SRTP by expanding the portion of the packet that is
encrypted, as shown in Packet Structure. It does not change how SRTP authentication
works in any way. Given that more of the packet is being encrypted than before,
this is necessarily an improvement.

The RTP fields that are left unencrypted (see rationale above) are as follows:

- RTP version
- padding bit
- extension bit
- number of CSRCs
- marker bit
- payload type
- sequence number
- timestamp
- SSRC identifier
- number of {{RFC8285}} header extensions

These values contain a fixed set (i.e., one that won't be changed by
extensions) of information that, at present, is observed to have low
sensitivity. In the event any of these values need to be encrypted, SRTP
is likely the wrong protocol to use and a fully-encapsulating protocol
such as DTLS is preferred (with its attendant per-packet overhead).

IANA Considerations
===================

This document defines two new 'defined by profile' attributes, as noted in RTP Header Processing.

Acknowledgements
================

The authors wish to thank Sergio Murillo, Jonathan Lennox, and Iñaki Castillo for
their review and text suggestions.

--- back
