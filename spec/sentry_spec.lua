local sentry = require "src/services/sentry"

describe("Sentry lua client", function()

  it("should generate a hash value", function()
    local hash = sentry.uuid()
    assert.are.equal(32, #hash)
  end)


  it("should accept an empty dsn", function()
    local client = sentry.newClient('')
    assert.is_nil(client:captureException())
  end)

  
  it("should parse a dsn", function()
    local dsn, err = sentry.parseDSN("https://public:secret@example.com/sentry/project-id")

    assert.are.equal('public', dsn.public)
    assert.are.equal('secret', dsn.secret)
    assert.are.equal('project-id', dsn.project)
    assert.are.equal('https://example.com/sentry/', dsn.uri)
  end)

end)
