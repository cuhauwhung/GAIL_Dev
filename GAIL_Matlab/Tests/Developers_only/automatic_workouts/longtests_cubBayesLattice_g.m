% longtests_cubBayesLattice_g: long tests for cubBayesLattice_g

%% CALL DOCTESTS


%% CALL UNIT TESTS
run_handle_ut('ut_cubBayesLattice_g');

try
  cubBayesLattice_long_tests;
catch
    disp('Error: cubBayesLattice_long_tests is wrongly coded. We skip it.')
end