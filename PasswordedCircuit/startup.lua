# TODO: Get password over network securely.
local targets = 'auto' -- Where is the redstone connected at? (Array or 'auto')
local password = 'Password' -- Whatever your password happens to be.

local shutdownTime = 15 -- How long should a failure wait when shutting down?
local dotFactor = 3 -- Divided by dotFactor to get the number of progress dots

local failLimit = 3 -- How many password attempts result in a failure?
local failCount = 0 -- How many password attempts have currently occured?

print 'Initializing monoSekure connection.'

function applyRedstone(_targets, value)
  local finalTargets = _targets

  if finalTargets == 'auto' then
    finalTargets = {
      'left',  'right',
      'top',   'bottom',
      'back',  'front'
    }
  end

  for index, target in pairs(finalTargets) do
    redstone.setOutput(target, value)
  end
end

function resetTerminal()
  term.clear()
  term.setCursorPos(1,1)
end

-- Prevent users from terminating via CTRL+T
os.pullEvent = os.pullEventRaw

while true do
  resetTerminal()

  print('Please enter the password.')

  input = read("*")

  print('Authenticating targets.')

  if input == tostring(password) then
    print('Authentication successful. Targets temporarily unlocked.')

    applyRedstone(targets, true)

    sleep(10)
    applyRedstone(targets, false)

    failCount = 0
  else
    failCount = failCount + 1

    write('Authentication failure. ')
    write(tostring(failLimit - failCount))
    print(' attempts remain.')

    if failCount >= failLimit then
      -- Now you've really gone and done it!
      resetTerminal()

      print('All attempts failed.')
      write('Initiating shutdown sequence.')

      for seconds=1, shutdownTime do
        if (seconds % 3) == 1 then
          write('.')
        end

        sleep(1)
      end

      write('\n')

      os.shutdown()
    end
  end
end

