source $SHPEC_ROOT/../scripts/pair

describe "pair"
  describe "variable sanitation"
    it "doesn't leak variables outside the function"
      (set -o posix; set) > /tmp/vars.before
      pair rylnd &> /dev/null
      (set -o posix; set) > /tmp/vars.after
      extra_vars=$(diff /tmp/vars.{before,after} --ignore-matching-lines=GIT_AUTHOR)
      rm /tmp/vars.{before,after}
      assert blank "$extra_vars"
  end_describe

  describe "exit codes"
    it "returns 0 when unsetting"
      pair -u &> /dev/null
      assert equal "$?" "0"

    it "returns 0 when printing help"
      pair -h &> /dev/null
      assert equal "$?" "0"

    it "returns 0 when printing config"
      pair &> /dev/null
      assert equal "$?" "0"

    it "returns 0 when all authors are found"
      pair rylnd &> /dev/null
      assert equal "$?" "0"

    it "returns nonzero if not all authors are found"
      pair rylnd _bad_user_ &> /dev/null
      assert equal "$?" "1"
  end_describe

  describe "setting of git environment variables"
    it "sets \$GIT_AUTHOR_NAME"
      pair rylnd &> /dev/null
      assert equal "$GIT_AUTHOR_NAME" "Ryland Herrick"

    it "sets \$GIT_AUTHOR_EMAIL"
      pair rylnd &> /dev/null
      assert match "$GIT_AUTHOR_EMAIL" "rylnd"

    it "unsets \$GIT_AUTHOR_NAME"
      pair -u &> /dev/null
      assert blank "$GIT_AUTHOR_NAME"

    it "unsets \$GIT_AUTHOR_EMAIL"
      pair -u &> /dev/null
      assert blank "$GIT_AUTHOR_EMAIL"

    it "uses pair@adorable.io in the email"
      pair rylnd &> /dev/null
      assert match "$GIT_AUTHOR_EMAIL" "pair.*adorable\.io"

    it "sets multiple usernames in the email"
      pair rylnd bendycode &> /dev/null
      assert match "$GIT_AUTHOR_EMAIL" "rylnd"
      assert match "$GIT_AUTHOR_EMAIL" "bendycode"

    it "sorts multiple usernames in the email alphabetically"
      pair rylnd bendycode &> /dev/null
      assert match "$GIT_AUTHOR_EMAIL" "bendycode.rylnd@"

    it "sets multiple names for the author"
      pair rylnd bendycode &> /dev/null
      assert match "$GIT_AUTHOR_NAME" "Ryland\ Herrick"
      assert match "$GIT_AUTHOR_NAME" "Stephen\ Anderson"

    it "sorts author names alphabetically by username"
      pair rylnd bendycode &> /dev/null
      assert equal "$GIT_AUTHOR_NAME" "Stephen Anderson and Ryland Herrick"

    it "correctly lists more than two authors WITH AN OXFORD COMMA"
      pair rylnd bendycode bigtiger &> /dev/null
      assert equal "$GIT_AUTHOR_NAME" "Stephen Anderson, Jim Remsik, and Ryland Herrick"
  end_describe

  describe "hybrid mode"
    it "finds unknown users from github"
      pair rylnd tenderlove &> /dev/null
      assert equal "$?" "0"
      assert equal "$GIT_AUTHOR_NAME" "Ryland Herrick and Aaron Patterson"

    describe "when offline"
      stub_command "curl"

      it "still works with local authors"
        pair rylnd &> /dev/null
        assert equal "$GIT_AUTHOR_NAME" "Ryland Herrick"

      it "fails if offline and the user is unknown"
        pair rylnd tenderlove &> /dev/null
        assert equal "$?" "1"

      unstub_command "curl"
    end_describe
  end_describe

  describe ".pairrc"
    it "doesn't rely on variables defined in the function"
      pair rylnd &> /dev/null
      source $HOME/.pairrc
      assert equal "$GIT_AUTHOR_NAME" "Ryland Herrick"
      assert match "$GIT_AUTHOR_EMAIL" "rylnd"
  end_describe

  describe "option handling"
    describe "unknown options"
      it "fails"
        pair -g 2>&1 > /dev/null
        assert equal "$?" "1"

      it "prints a helpful message"
        message=$(pair -g)
        assert equal "$message" "Unknown option: '-g'"
    end_describe

    describe "help message"
      it "prints usage and examples"
        message=$(pair -h)
        assert match "$message" "Usage"
        assert match "$message" "Examples"
    end_describe
  end_describe

  it "alerts if not all authors are found"
    stub_command "curl" "cat shpec/fixtures/_bad_user_.json"

    message=$(pair rylnd _bad_user_)
    assert match "$message" "No\ user\ found\ for\ GitHub\ username:\ _bad_user_"

    unstub_command "curl"

  it "does nothing if it can't find all authors"
    stub_command "curl" "cat shpec/fixtures/_bad_user_.json"

    pair -u &> /dev/null
    pair rylnd _bad_user_ &> /dev/null
    assert blank "$GIT_AUTHOR_NAME"
    assert blank "$GIT_AUTHOR_EMAIL"

    unstub_command "curl"

  it "falls back to username for nonlocal usernames that don't have a full name set on Github"
    stub_command "curl" "cat shpec/fixtures/github_user_no_full_name.json"

    message=$(pair rylnd no_full_name)
    assert match "$message" "No\ author\ name\ found\ for\ GitHub\ username:\ no_full_name"

    unstub_command "curl"
end_describe

## TEARDOWN
  pair -u &> /dev/null
