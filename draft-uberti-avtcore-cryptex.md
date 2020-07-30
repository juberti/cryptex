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

Security Considerations
=======================

The specification does not change how SRTP authentication works in any
way. It only changes encryption to expand the portion of the packet that
is encrypted. Given theses two points, the authors do not feel it in any
way makes the security worse than SRTP.

This extension improves the security of SRTP by encrypting all the
header extension data other than the total length of all the combined
header extensions. It also encrypts the values of the CSRC identifiers
but not the number of identifiers.

The leaves unencrypted the following items which are not encrypted by
SRTP: the version of RTP, total length of extension, amount of padding,
number of CSRC, the maker bit, the payload type number, the RTP sequence
number, timestamp, and SSRC. These values are either need to be encrypt
for SRTP processing or have very little information that has any value
in encrypting. If any of theses values need to be encrypted, DTLS-SRTP
is likely the wrong protocol to use and instead the RTP should be sent
over a fully encrypted protocol such as DTLS or TLS.

IANA Considerations
===================

Acknowledgements
================

