### Start API
`rakeup`
#### Add a new actionkiq task
`post '/action', { 'tags' => 'any_tag' }`

### Start ackionkiq
`ruby index.rb`

### Make a pause - SIGTSTP
`kill -TSTP <pid>`

### Resume a pause - SIGUSR2
`kill -USR2 <pid>`

### Shut down the program.
`Press Ctrl+C (SIGINT) or send SIGTERM`

### Get pids
`ps ax  | grep ruby`
