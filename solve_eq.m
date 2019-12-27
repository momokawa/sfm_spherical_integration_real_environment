function g = solve_eq(U)
    [v,~]=eig(U'*U);
    g=v(:,1);
    g = g/g(end);
    g(end) = [];
    g = g';
end