#!/usr/bin/env node

const getLatestGithubTag = require('latest-github-tag')
const { execFileSync: exec, spawn } = require('child_process')
const { EOL } = require('os')

const { SOURCE, SOURCE_DIR } = process.env

;(async () => {
	const latestSourceTag = await getLatestGithubTag(...SOURCE.split('/'), { timeout: 10000 })
	const tags = exec('git', [ 'tag' ]).toString().trim().split(EOL)
	if (!tags.includes(latestSourceTag)) {
		spawn(`${__dirname}/update.sh`, [ latestSourceTag ], { cwd: SOURCE_DIR, stdio: 'inherit' })
			.on('exit', code => process.exit(code))
	}
})()
