package test_util;
    // An assertion that terminates immediately with an error exit code on
    // failure.
    //
    // All tests should use exclusively this over assert, because icarus
    // default behavour is to terminate with a success code even if assertions
    // have failed during execution. This would cause tests in CI to pass when
    // assertions are failing.
    task fatal_assert(logic condition);
        assert(condition) else $fatal;
    endtask
endpackage
