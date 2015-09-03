chai = require 'chai'
chai.should()
expect = chai.expect




{validateAuthorizationParams} = require '../../../oidc'
settings = require '../../../boot/settings'




req = (params) -> connectParams: params, cookies: { 'connect.sid': 'secret' }
res = {}
err = null




describe 'Validate Authorization Parameters', ->

  describe 'all requests', ->

    describe 'with missing redirect_uri', ->

      before (done) ->
        params = {}
        validateAuthorizationParams req(params), res, (error) ->
          err = error
          done()

      it 'should provide an AuthorizationError', ->
        err.name.should.equal 'AuthorizationError'

      it 'should provide an error code', ->
        err.error.should.equal 'invalid_request'

      it 'should provide an error description', ->
        err.error_description.should.equal 'Missing redirect uri'

      it 'should provide a status code', ->
        err.statusCode.should.equal 400




    describe 'with invalid redirect_uri', ->

      it 'should provide an AuthorizationError'
      it 'should provide an error code'
      it 'should provide an error description'
      it 'should provide a redirect_uri'
      it 'should provide a status code'




    describe 'with missing response_type', ->

      before (done) ->
        params = { redirect_uri: 'https://redirect.uri' }
        validateAuthorizationParams req(params), res, (error) ->
          err = error
          done()

      it 'should provide an AuthorizationError', ->
        err.name.should.equal 'AuthorizationError'

      it 'should provide an error code', ->
        err.error.should.equal 'invalid_request'

      it 'should provide an error description', ->
        err.error_description.should.equal 'Missing response type'

      it 'should provide a redirect_uri', ->
        err.redirect_uri.should.equal 'https://redirect.uri'

      it 'should provide a status code', ->
        err.statusCode.should.equal 302




    describe 'with only whitespace for a response_type', ->

      before (done) ->
        params =
          redirect_uri: 'https://redirect.uri'
          response_type: '    '
        validateAuthorizationParams req(params), res, (error) ->
          err = error
          done()

      it 'should provide an AuthorizationError', ->
        err.name.should.equal 'AuthorizationError'

      it 'should provide an error code', ->
        err.error.should.equal 'invalid_request'

      it 'should provide an error description', ->
        err.error_description.should.equal 'Missing response type'

      it 'should provide a redirect_uri', ->
        err.redirect_uri.should.equal 'https://redirect.uri'

      it 'should provide a status code', ->
        err.statusCode.should.equal 302




    describe 'with invalid response_type', ->

      before (done) ->
        params =
          redirect_uri: 'https://redirect.uri'
          response_type: 'invalid'

        validateAuthorizationParams req(params), res, (error) ->
          err = error
          done()

      it 'should provide an AuthorizationError', ->
        err.name.should.equal 'AuthorizationError'

      it 'should provide an error code', ->
        err.error.should.equal 'unsupported_response_type'

      it 'should provide an error description', ->
        err.error_description.should.equal 'Unsupported response type'

      it 'should provide a redirect_uri', ->
        err.redirect_uri.should.equal 'https://redirect.uri'

      it 'should provide a status code', ->
        err.statusCode.should.equal 302




    describe 'with unsupported response_type', ->

      supportedResponseTypes = settings.response_types_supported

      before (done) ->
        settings.response_types_supported = [
          'code',
          'id_token token',
          'code id_token token'
        ]

        params =
          redirect_uri: 'https://redirect.uri'
          response_type: 'code token'

        validateAuthorizationParams req(params), res, (error) ->
          err = error
          done()

      after ->
        settings.response_types_supported = supportedResponseTypes

      it 'should provide an AuthorizationError', ->
        err.name.should.equal 'AuthorizationError'

      it 'should provide an error code', ->
        err.error.should.equal 'unsupported_response_type'

      it 'should provide an error description', ->
        err.error_description.should.equal 'Unsupported response type'

      it 'should provide a redirect_uri', ->
        err.redirect_uri.should.equal 'https://redirect.uri'

      it 'should provide a status code', ->
        err.statusCode.should.equal 302




    describe 'with extraneous response_type', ->

      before (done) ->
        params =
          redirect_uri: 'https://redirect.uri'
          response_type: 'none code'
          client_id: 'uuid'
          scope: 'openid'

        validateAuthorizationParams req(params), res, (error) ->
          err = error
          done()

      it 'should provide an AuthorizationError', ->
        err.name.should.equal 'AuthorizationError'

      it 'should provide an error code', ->
        err.error.should.equal 'unsupported_response_type'

      it 'should provide an error description', ->
        err.error_description.should.equal 'Unsupported response type'

      it 'should provide a redirect_uri', ->
        err.redirect_uri.should.equal 'https://redirect.uri'

      it 'should provide a status code', ->
        err.statusCode.should.equal 302




    describe 'with supported and rearranged response_type', ->

      supportedResponseTypes = settings.response_types_supported

      before (done) ->
        settings.response_types_supported = [
          'code',
          'id_token token',
          'code id_token token'
        ]

        params =
          redirect_uri: 'https://redirect.uri'
          response_type: 'code token id_token'
          client_id: 'uuid'
          scope: 'openid'
          nonce: 'nonce'

        validateAuthorizationParams req(params), res, (error) ->
          err = error
          done()

      after ->
        settings.response_types_supported = supportedResponseTypes

      it 'should not provide an error', ->
        expect(err).to.not.be.ok




    describe 'with unsupported response_mode', ->

      before (done) ->
        params =
          redirect_uri: 'https://redirect.uri'
          response_type: 'id_token token'
          response_mode: 'unsupported'

        validateAuthorizationParams req(params), res, (error) ->
          err = error
          done()

      it 'should provide an AuthorizationError', ->
        err.name.should.equal 'AuthorizationError'

      it 'should provide an error code', ->
        err.error.should.equal 'unsupported_response_mode'

      it 'should provide an error description', ->
        err.error_description.should.equal 'Unsupported response mode'

      it 'should provide a redirect_uri', ->
        err.redirect_uri.should.equal 'https://redirect.uri'

      it 'should provide a status code', ->
        err.statusCode.should.equal 302




    describe 'with missing client_id', ->

      before (done) ->
        params =
          redirect_uri: 'https://redirect.uri'
          response_type: 'code'

        validateAuthorizationParams req(params), res, (error) ->
          err = error
          done()

      it 'should provide an AuthorizationError', ->
        err.name.should.equal 'AuthorizationError'

      it 'should provide an error code', ->
        err.error.should.equal 'unauthorized_client'

      it 'should provide an error description', ->
        err.error_description.should.equal 'Missing client id'

      it 'should provide a status code', ->
        err.statusCode.should.equal 403




    describe 'with missing scope', ->

      before (done) ->
        params =
          redirect_uri: 'https://redirect.uri'
          response_type: 'code'
          client_id: 'uuid'

        validateAuthorizationParams req(params), res, (error) ->
          err = error
          done()

      it 'should provide an AuthorizationError', ->
        err.name.should.equal 'AuthorizationError'

      it 'should provide an error code', ->
        err.error.should.equal 'invalid_scope'

      it 'should provide an error description', ->
        err.error_description.should.equal 'Missing scope'

      it 'should provide a redirect_uri', ->
        err.redirect_uri.should.equal 'https://redirect.uri'

      it 'should provide a status code', ->
        err.statusCode.should.equal 302




    describe 'with missing "openid" scope', ->

      before (done) ->
        params =
          redirect_uri: 'https://redirect.uri'
          response_type: 'code'
          client_id: 'uuid'
          scope: 'insufficient'

        validateAuthorizationParams req(params), res, (error) ->
          err = error
          done()

      it 'should provide an AuthorizationError', ->
        err.name.should.equal 'AuthorizationError'

      it 'should provide an error code', ->
        err.error.should.equal 'invalid_scope'

      it 'should provide an error description', ->
        err.error_description.should.equal 'Missing openid scope'

      it 'should provide a redirect_uri', ->
        err.redirect_uri.should.equal 'https://redirect.uri'

      it 'should provide a status code', ->
        err.statusCode.should.equal 302




  describe 'for implicit flow requests', ->

    describe 'with missing nonce', ->

      before (done) ->
        params =
          redirect_uri: 'https://redirect.uri'
          response_type: 'id_token token'
          client_id: 'uuid'
          scope: 'openid'

        validateAuthorizationParams req(params), res, (error) ->
          err = error
          done()

      it 'should provide an AuthorizationError', ->
        err.name.should.equal 'AuthorizationError'

      it 'should provide an error code', ->
        err.error.should.equal 'invalid_request'

      it 'should provide an error description', ->
        err.error_description.should.equal 'Missing nonce'

      it 'should provide a redirect_uri', ->
        err.redirect_uri.should.equal 'https://redirect.uri'

      it 'should provide a status code', ->
        err.statusCode.should.equal 302
