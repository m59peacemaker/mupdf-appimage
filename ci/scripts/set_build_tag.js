#!/usr/bin/env node

const { execFileSync: exec } = require('child_process')
const { EOL } = require('os')
const semver = require('semver')

const { PROJECT_ROOT, SOURCE_DIR } = process.env

const gitTags = dir => exec('git', [ 'tag' ], { cwd: dir }).toString().trim().split(EOL)

;(async () => {
	const sourceTags = gitTags(SOURCE_DIR)
	const tags = gitTags(PROJECT_ROOT)
	const latestSourceTag = sourceTags.filter(semver.valid).sort(semver.rcompare)[0]
	if (!tags.includes(latestSourceTag)) {
		console.log(`::set-output name=build_tag::${latestSourceTag}`)
	}
})()
