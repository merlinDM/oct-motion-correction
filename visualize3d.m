function visualize3d(varargin)


for i = 1:nargin
    if ndims(varargin{i}) ~= 3
        msgID = 'OCT:BadArguments';
        msg   = sprintf('3D Matrix expected on position %i', i);
        ex    = MException(msgID, msg);
        throw(ex);
    end
end

fps = 10;
duration = 1000;
floorPosition = 1;
plots = nargin;

pause on;
for y = 1:duration
    
    for j = 1:nargin
        row = j;
        subplot(plots,1,row);

        data = varargin{j};

        NMAX = size(data, 1);
        MNAX = size(data, 2);
        slice(data, ...
            (NMAX), (mod(y, MNAX) + 1), (floorPosition))
    end

    pause(1/fps);
end

end

