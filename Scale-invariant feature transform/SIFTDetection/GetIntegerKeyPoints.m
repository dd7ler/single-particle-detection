function [IntegerKeyPoints]=GetIntegerKeyPoints(KeyPoints)

RoundPixelLocations=round(KeyPoints(1:2,:)).';
