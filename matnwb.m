classdef matnwb < types.NWBFile
  methods
    function obj = matnwb(varargin)
      obj = obj@types.NWBFile(varargin{:});
    end
    
    function ref = getFromPath(obj, path)
      ref = obj(path);
    end
    
    function varargout = subsref(obj, s)
      switch s(1).type
        case {'()', '{}'} %traverse through NWBFile given NWB path
            sub = s(1).subs{1}; %only grab the first
            
            ref = obj;
            for token=parsePath(obj, sub)'
              ref = ref.(token{1});
              if isa(ref, 'types.untyped.Link') %automatically dereference links
                ref = ref.ref;
              end
            end
            if length(s) > 1
              ref = subsref(ref, s(2:end));
            end
          varargout{1} = ref;
        case '.'
          [varargout{1:nargout}] = builtin('subsref', obj, s);
      end
    end
    
    function export(obj, filename)
      validateattributes(filename, {'string', 'char'}, {'scalartext'});
      if exist(filename, 'file')
        warning('Overwriting %s', filename);
        delete(filename);
      end
      fid = H5F.create(filename);
      export@types.NWBFile(obj, fid);
      H5F.close(fid);
    end
  end
  methods(Access=private)
    function tok = parsePath(~, path)
      validateattributes(path, {'char', 'string'}, {'scalartext'});
      if startsWith(path, '/')
        splitidx = 2;
      else
        splitidx = 1;
      end
      tok = split(path(splitidx:end), '/');
    end
  end
end