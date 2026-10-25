# Response fixtures

`captured-nova3-diarized-utterances.json` is copied byte for byte from
TranscriptionKit's `Tests/TranscriptionKitDeepgramTests/Resources/Responses/`.
It was captured on 2026-10-24 from Deepgram POST /v1/listen with nova-3,
diarize, utterances, punctuate, and smart_format, using Deepgram's sample
https://dpgr.am/spacewalk.wav. The fixture is replayed without network access in offline tests.

Error bodies in the test source are representative fixtures derived from
https://developers.deepgram.com/docs/errors, not live captures.

`captured-error-401.json` is the unedited body from a 2026-10-25 POST to
https://api.deepgram.com/v1/listen using a deliberately invalid API key and a
JSON body containing the same sample URL. The service returned HTTP 401.
No real credentials were sent for this capture. Offline tests replay the body.
A fresh HTTP 400 capture needs configured Deepgram credentials; the current
400 tests use documented representative fixtures instead.
