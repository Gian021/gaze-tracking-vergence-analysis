function Ds = straighten(D)

while(any(diff(D)<0))
    pos = find(diff(D)<0,1);

    D(pos+1:end) = D(pos) - D(pos+1) + D(pos+1:end) + nanmedian(diff(D(1:pos)));
end

Ds = D;
