require 'spec_helper'

describe Profile do

    describe :factory do
        describe :profile do
            it 'creates a valid model' do
                FactoryGirl.create( :profile ).should be_valid
            end
        end

        describe :profile_default do
            it 'creates a valid model' do
                FactoryGirl.create( :profile_default ).should be_valid
            end
            it 'creates a default profile' do
                FactoryGirl.create( :profile_default ).should be_default
            end
        end
    end

    describe :validation do
        describe :name do
            context 'when empty' do
                it 'is invalid' do
                    FactoryGirl.build( :profile, name: '' ).should be_invalid
                end
            end

            it 'should be unique per owner' do
                owner = FactoryGirl.create( :user )
                FactoryGirl.create( :profile, name: 'Name here', owner: owner ).should be_valid
                FactoryGirl.build( :profile, name: 'Name here', owner: owner ).should be_invalid
            end

            it 'should not be unique across different owners' do
                FactoryGirl.create( :profile, name: 'Name here' ).should be_valid
                FactoryGirl.create( :profile, name: 'Name here' ).should be_valid
            end
        end

        describe :description do
            context 'when it contains HTML' do
                it 'is invalid' do
                    FactoryGirl.build( :profile, description: '<em>Stuff...<em>' ).
                        should be_invalid
                end
            end

            context 'when it does not contain HTML' do
                it 'is valid' do
                    FactoryGirl.build( :profile, description: 'Stuff...' ).
                        should be_valid
                end
            end
        end

        describe :redundant do
            context 'when incorrectly formatted' do
                context 'with a non-numeric counter' do
                    it 'should be invalid' do
                        r = { 'skip' => 'blah' }
                        FactoryGirl.build( :profile, redundant: r ).should be_invalid
                    end
                end
                context 'with a counter of 0' do
                    it 'should be invalid' do
                        r = { 'skip' => 0 }
                        FactoryGirl.build( :profile, redundant: r ).should be_invalid
                    end
                end
                context 'with a counter < 0' do
                    it 'should be invalid' do
                        r = { 'skip' => -1 }
                        FactoryGirl.build( :profile, redundant: r ).should be_invalid
                    end
                end
            end

            context 'when correctly formatted' do
                context 'with a numeric counter' do
                    it 'should be valid' do
                        r = { 'skip' => 1, 'skip2' => 2 }
                        FactoryGirl.build( :profile, redundant: r ).should be_valid
                    end
                end
                context 'with a string representation of a numeric counter' do
                    it 'should be valid' do
                        r = { 'skip' => '1', 'skip2' => '2' }
                        FactoryGirl.build( :profile, redundant: r ).should be_valid
                    end
                end
            end
        end

        describe :cookies do
            context 'when incorrectly formatted' do
                context 'with an empty name' do
                    it 'should be invalid' do
                        c = { '' => 'blah' }
                        FactoryGirl.build( :profile, cookies: c ).should be_invalid
                    end
                end
            end

            context 'when correctly formatted' do
                it 'should be valid' do
                    c = { 'name' => 'blah' }
                    FactoryGirl.build( :profile, cookies: c ).should be_valid
                end
            end
        end

        describe :custom_headers do
            context 'when incorrectly formatted' do
                context 'with an empty name' do
                    it 'should be invalid' do
                        c = { '' => 'blah' }
                        FactoryGirl.build( :profile, custom_headers: c ).should be_invalid
                    end
                end
            end

            context 'when correctly formatted' do
                it 'should be valid' do
                    c = { 'name' => 'blah' }
                    FactoryGirl.build( :profile, custom_headers: c ).should be_valid
                end
            end
        end

        describe :login_check do
            context 'when it has a login_check_url' do
                context 'but not a login_check_pattern' do
                    it 'should be invalid' do
                        FactoryGirl.build( :profile,
                                           login_check_url: 'http://test.com' ).should be_invalid
                    end
                end
            end

            context 'when it has a login_check_pattern' do
                context 'but not a login_check_url' do
                    it 'should be invalid' do
                        FactoryGirl.build( :profile,
                                           login_check_pattern: /stuff/ ).should be_invalid
                    end
                end
            end

            context 'when login_check_url is not a valid absolute URL' do
                it 'should be invalid' do
                    FactoryGirl.build( :profile,
                                       login_check_url: '/stuff/' ).should be_invalid
                end
            end

            context 'when it has a valid login_check_url' do
                context 'and a login_check_pattern' do
                    it 'should be valid' do
                        FactoryGirl.build( :profile,
                                           login_check_url:     'http://test.com/stuff/',
                                           login_check_pattern: /stuff/ ).should be_valid
                    end
                end
            end
        end

        #describe :modules do
        #    context 'when given a module that does not exist' do
        #        it 'should be invalid' do
        #            FactoryGirl.build( :profile, modules: %w(stuff) ).should be_invalid
        #        end
        #    end
        #end

        describe :plugins do
            context 'when given a plugin that does not exist' do
                it 'should be invalid' do
                    FactoryGirl.build( :profile, plugins: {'stuff' => {}} ).should be_invalid
                end
            end

            context 'when given plugins that exist' do
                it 'should be valid' do
                    plugin = ::FrameworkHelper.plugins.keys.first.to_s
                    FactoryGirl.build( :profile, plugins: { plugin => {}} ).should be_invalid
                end
            end
        end
    end

    describe :scope do
        describe :global do
            it 'returns global profiles' do
                3.times { FactoryGirl.create( :profile ) }
                globals = (0..2).map { FactoryGirl.create( :profile_global ) }

                Profile.global.should =~ globals
            end
        end
    end

    #describe '#make_default' do
    #    it 'should make the given profile the default one' do
    #        p = FactoryGirl.create( :profile )
    #
    #        p.make_default
    #        p.default.should be_true
    #    end
    #    it 'should remove the default status from the previous default profile' do
    #        p = FactoryGirl.create( :profile )
    #
    #        p.make_default
    #        p.default?.should be_true
    #
    #        p2 = FactoryGirl.create( :profile )
    #
    #        p2.make_default
    #
    #        Profile.find( p2.id ).default?.should be_true
    #        Profile.find( p.id ).default?.should be_false
    #    end
    #end
    #
    #describe '#name' do
    #    it 'should be required' do
    #        Profile.create.errors.messages.include?( :name ).should be_true
    #        FactoryGirl.create( :profile ).errors.should be_empty
    #    end
    #    it 'should be unique' do
    #        Profile.create( name: 'stuff', description: 'Desc' ).save
    #        p = Profile.create( name: 'stuff', description: 'Desc' )
    #        p.errors.messages.include?( :name ).should be_true
    #    end
    #end
    #
    #describe '#description' do
    #    it 'should be required' do
    #        Profile.create.errors.messages.include?( :name ).should be_true
    #        FactoryGirl.create( :profile ).errors.should be_empty
    #    end
    #end
    #
    #describe '#redundant=' do
    #    before { @expected = { "match-this" => "3", "match_this_too" => "4" } }
    #    context 'when the parameter is a' do
    #        context String do
    #            it 'should be parsed and converted to a Hash before saving' do
    #                p = FactoryGirl.create( :profile )
    #                p.redundant = "match-this:3\nmatch_this_too:4"
    #                p.redundant.should == @expected
    #
    #                p = FactoryGirl.create( :profile )
    #                p.redundant = "match-this:3\n\rmatch_this_too:4"
    #                p.redundant.should == @expected
    #            end
    #        end
    #        context Hash do
    #            it 'should be saved' do
    #                p = FactoryGirl.create( :profile )
    #                p.redundant = @expected
    #                p.redundant.should == @expected
    #            end
    #        end
    #    end
    #end
    #
    #describe '#exclude=' do
    #    before { @expected = [ "exclude this", "this-too!" ] }
    #    context 'when the parameter is a' do
    #        context String do
    #            it 'should be parsed and converted to an Array before saving' do
    #                p = FactoryGirl.create( :profile )
    #                p.exclude = "exclude this\nthis-too!"
    #                p.exclude.should == @expected
    #
    #                p = FactoryGirl.create( :profile )
    #                p.exclude = "exclude this\n\rthis-too!"
    #                p.exclude.should == @expected
    #            end
    #        end
    #        context Array do
    #            it 'should be saved' do
    #                p = FactoryGirl.create( :profile )
    #                p.exclude = @expected
    #                p.exclude.should == @expected
    #            end
    #        end
    #    end
    #end
    #
    #describe '#include=' do
    #    before { @expected = [ "include this", "this-too!" ] }
    #    context 'when the parameter is a' do
    #        context String do
    #            it 'should be parsed and converted to an Array before saving' do
    #                p = FactoryGirl.create( :profile )
    #                p.include = "include this\nthis-too!"
    #                p.include.should == @expected
    #
    #                p = FactoryGirl.create( :profile )
    #                p.include = "include this\n\rthis-too!"
    #                p.include.should == @expected
    #            end
    #        end
    #        context Array do
    #            it 'should be saved' do
    #                p = FactoryGirl.create( :profile )
    #                p.include = @expected
    #                p.include.should == @expected
    #            end
    #        end
    #    end
    #end
    #
    #describe '#restrict_paths=' do
    #    before { @expected = [ "include this", "this-too!" ] }
    #    context 'when the parameter is a' do
    #        context String do
    #            it 'should be parsed and converted to an Array before saving' do
    #                p = FactoryGirl.create( :profile )
    #                p.restrict_paths = "include this\nthis-too!"
    #                p.restrict_paths.should == @expected
    #
    #                p = FactoryGirl.create( :profile )
    #                p.restrict_paths = "include this\n\rthis-too!"
    #                p.restrict_paths.should == @expected
    #            end
    #        end
    #        context Array do
    #            it 'should be saved' do
    #                p = FactoryGirl.create( :profile )
    #                p.restrict_paths = @expected
    #                p.restrict_paths.should == @expected
    #            end
    #        end
    #    end
    #end
    #
    #describe '#extend_paths=' do
    #    before { @expected = [ "include this", "this-too!" ] }
    #    context 'when the parameter is a' do
    #        context String do
    #            it 'should be parsed and converted to an Array before saving' do
    #                p = FactoryGirl.create( :profile )
    #                p.extend_paths = "include this\nthis-too!"
    #                p.extend_paths.should == @expected
    #
    #                p = FactoryGirl.create( :profile )
    #                p.extend_paths = "include this\n\rthis-too!"
    #                p.extend_paths.should == @expected
    #            end
    #        end
    #        context Array do
    #            it 'should be saved' do
    #                p = FactoryGirl.create( :profile )
    #                p.extend_paths = @expected
    #                p.extend_paths.should == @expected
    #            end
    #        end
    #    end
    #end
    #
    #describe '#exclude_vectors=' do
    #    before { @expected = [ "include this", "this-too!" ] }
    #    context 'when the parameter is a' do
    #        context String do
    #            it 'should be parsed and converted to an Array before saving' do
    #                p = FactoryGirl.create( :profile )
    #                p.exclude_vectors = "include this\nthis-too!"
    #                p.exclude_vectors.should == @expected
    #
    #                p = FactoryGirl.create( :profile )
    #                p.exclude_vectors = "include this\n\rthis-too!"
    #                p.exclude_vectors.should == @expected
    #            end
    #        end
    #        context Array do
    #            it 'should be saved' do
    #                p = FactoryGirl.create( :profile )
    #                p.exclude_vectors = @expected
    #                p.exclude_vectors.should == @expected
    #            end
    #        end
    #    end
    #end
    #
    #describe '#exclude_cookies=' do
    #    before { @expected = [ "include this", "this-too!" ] }
    #    context 'when the parameter is a' do
    #        context String do
    #            it 'should be parsed and converted to an Array before saving' do
    #                p = FactoryGirl.create( :profile )
    #                p.exclude_cookies = "include this\nthis-too!"
    #                p.exclude_cookies.should == @expected
    #
    #                p = FactoryGirl.create( :profile )
    #                p.exclude_cookies = "include this\n\rthis-too!"
    #                p.exclude_cookies.should == @expected
    #            end
    #        end
    #        context Array do
    #            it 'should be saved' do
    #                p = FactoryGirl.create( :profile )
    #                p.exclude_cookies = @expected
    #                p.exclude_cookies.should == @expected
    #            end
    #        end
    #    end
    #end
    #
    #describe '#cookies=' do
    #    before { @expected = { "sessionid" => "deadbeefbabe", "user" => "john.doe" } }
    #    context 'when the parameter is a' do
    #        context String do
    #            it 'should be parsed and converted to a Hash before saving' do
    #                p = FactoryGirl.create( :profile )
    #                p.cookies = "sessionid=deadbeefbabe\nuser=john.doe"
    #                p.cookies.should == @expected
    #
    #                p = FactoryGirl.create( :profile )
    #                p.cookies = "sessionid=deadbeefbabe\n\ruser=john.doe"
    #                p.cookies.should == @expected
    #            end
    #        end
    #        context Hash do
    #            it 'should be saved' do
    #                p = FactoryGirl.create( :profile )
    #                p.cookies = @expected
    #                p.cookies.should == @expected
    #            end
    #        end
    #    end
    #end
    #
    #describe '#custom_headers=' do
    #    before { @expected = { "From" => "john.dow@stuff.com", "X-Custom" => "hihihi" } }
    #    context 'when the parameter is a' do
    #        context String do
    #            it 'should be parsed and converted to a Hash before saving' do
    #                p = FactoryGirl.create( :profile )
    #                p.custom_headers = "From=john.dow@stuff.com\nX-Custom=hihihi"
    #                p.custom_headers.should == @expected
    #
    #                p = FactoryGirl.create( :profile )
    #                p.custom_headers = "From=john.dow@stuff.com\n\rX-Custom=hihihi"
    #                p.custom_headers.should == @expected
    #            end
    #        end
    #        context Hash do
    #            it 'should be saved' do
    #                p = FactoryGirl.create( :profile )
    #                p.custom_headers = @expected
    #                p.custom_headers.should == @expected
    #            end
    #        end
    #    end
    #end
    #
    #describe '#modules=' do
    #    context 'when the parameter is' do
    #        context :all do
    #            it 'should save all available modules' do
    #                p = FactoryGirl.create( :profile )
    #                p.modules = :all
    #                p.modules.should == ::FrameworkHelper.modules.keys
    #            end
    #        end
    #        context :default do
    #            it 'should save all available modules' do
    #                p = FactoryGirl.create( :profile )
    #                p.modules = :default
    #                p.modules.should == ::FrameworkHelper.modules.keys
    #            end
    #        end
    #        context Array do
    #            it 'should be saved' do
    #                p = FactoryGirl.create( :profile )
    #                p.modules = [ :xss, 'sqli' ]
    #                p.modules.should == [ :xss, 'sqli' ]
    #            end
    #        end
    #    end
    #end
    #
    #describe '#plugins=' do
    #    context 'when the parameter is' do
    #        context :default do
    #            it 'should save all default plugins' do
    #                p = FactoryGirl.create( :profile )
    #                p.modules = :default
    #                p.modules.should == ::FrameworkHelper.modules.keys
    #            end
    #        end
    #        context Hash do
    #            it 'should be saved' do
    #                p = FactoryGirl.create( :profile )
    #                p.modules = [ :xss, 'sqli' ]
    #                p.modules.should == [ :xss, 'sqli' ]
    #            end
    #        end
    #    end
    #end

end
