# Contributing

TODO

## LLM contributions

If you use LLM assistance, including research or review, attribute it in each
affected commit's footer, even if you write and commit the changes yourself. The
trailer lets a commit's trust be re-calibrated later, once more is known about
the model. PRs missing required attribution will be rejected.

| Footers | Meaning |
| --- | --- |
| `Assisted-by` | Awaiting human sign-off; may be shared in a draft PR. |
| `Assisted-by` + `Signed-off-by` | Reviewed; the signer understands and takes responsibility. |
| `Generated-by` | Records LLM contributions without claiming human review. |

Signing off (`git commit -s`) means you have read and reviewed the code,
understand the changes, and take responsibility for the commit's contents. If an
LLM agent rewrites the commit and its git tree hash changes, it must remove the
existing sign-offs. A human signs off again after reviewing.

`Assisted-by` alone is insufficient for acceptance. A human may instead choose
to land unreviewed work using `Generated-by`, but such commits from external
contributors are unlikely to be accepted.

Mistakes in code you wrote are fine; review can help you learn from them. The
maintainer needs to trust what you say about how you produced the code and what
you've reviewed. Submitting bad LLM output without attribution means the
maintainer stops reviewing your work, because you're asking for that review
under false pretenses. Signing off on code you don't understand has the same
result. Future readers rely on that sign-off, and the history gives them no way
to know it was false.

See [AGENTS.md](AGENTS.md#llm-provenance) for the trailer format and full
policy.
