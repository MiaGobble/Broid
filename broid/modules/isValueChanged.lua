-- Author: iGottic

return function(OldValue, NewValue)
    if type(OldValue) ~= type(NewValue) then
        return true
    end

    return OldValue ~= NewValue
end