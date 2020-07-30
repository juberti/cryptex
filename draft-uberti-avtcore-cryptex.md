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

## Sending

When sending an RTP packet that requires any header extensions to a
destination that has negotiated header encryption, the header extensions
be encapsulated inside a {{RFC8285}} header extension.

The 16 bit RTP header extension tag MUST be changed from 0xBEDE to
0xC0DE to indicate that it will be encrypted.

## Receiving

After decrypting and authenticating the packet, if there is an RPT
header extension with a 16 bit RTP header extension tag of 0xC0DE, it
MUST be changed from 0xC0DE to 0xBEDE so that it can b processed as a
normal {{RFC8285}} header extension.

Encryption and Decryption
=========================

Security Considerations
=======================

IANA Considerations
===================

TODO: allocate RTP header extension code 0xC0DE to this spec

Acknowledgements
================

