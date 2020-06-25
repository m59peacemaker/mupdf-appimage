#!/usr/bin/env node

const getLatestGithubTag = require('latest-github-tag')
const { execFileSync: exec } = require('child_process')
const { EOL } = require('os')

const { SOURCE } = process.env

;(async () => {
	const latestSourceTag = await getLatestGithubTag(...SOURCE.split('/'), { timeout: 10000 })
	const tags = exec('git', [ 'tag' ]).toString().trim().split(EOL)
	if (!tags.includes(latestSourceTag)) {
		console.log(`::set-output name=build_tag::${latestSourceTag}`)
	}
})()
