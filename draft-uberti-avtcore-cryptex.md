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

IANA Considerations
===================

Acknowledgements
================

