---
docname: draft-uberti-avtcore-cryptex-latest
title: Completely Encrypting RTP Header Extensions and Contributing Sources

ipr: trust200902
area: General
workgroup: AVTCORE
keyword: Internet-Draft

stand_alone: yes
pi: [toc, sortrefs, symrefs]

author:
-
    ins: J. Uberti
    name: Justin Uberti
    organization: Google
    email: justin@uberti.name

normative:
  RFC2119:
  
informative:
  RFC6904:

--- abstract

While the Secure Real-time Transport Protocol (SRTP) protects the contents of a media packet from eavesdroppers, a significant amount of metadata is still visible in the form of RTP header extensions and contributing sources (CSRCs). Previous approaches to protect this data have had limited deployment, due to complexity as well as technical limitations. This document proposes a new mechanism to completely encrypt header extensions and CSRCs with a new signaling mechanism to facilitate deployment.

--- middle

Introduction 
===========

Terminology
===========
The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in {{RFC2119}}.

Design
======

Signaling
=========

RTP Header Processing
=====================

Encryption and Decryption
=========================

## Sending

When encrypting an RTP packet, it is identical to {{RFC3711}} other
than in step 5 of Section 3.3, instead of encrypting the RTP Payload, a
slightly different set of bits is encrypted.

For RTP packets with the x bit set to 0, the bits to encrypt consist of
all of the RTP header after the first 12 bytes of the RTP header and the
RTP Payload.

For RTP packets with the x bit set to 1, the bytes to encrypt are formed
by skipping the first 12 bytes of the packet, including the rest of the
RTP header bytes up up to the start of the RTP header extensions,
skipping the first 4 bytes of the header extension, then include the rest
of header extension bytes and the RTP Payload.


## Receiving

When decrypting an RTP packet, it is identical to {{RFC3711}} other
than in step 6 of Section 3.3, instead of decrypting the RTP Payload,
the bytes decrypted match the bytes to be encrypt in the previous
section.


Security Considerations
=======================

IANA Considerations
===================

Acknowledgements
================

