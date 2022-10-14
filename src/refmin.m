# Copyright (C) 2022 Alexandre Umpierre
#
# This file is part of ponchon-savarit toolbox.
# ponchon-savarit toolbox is free software:
# you can redistribute it and/or modify it under the terms
# of the GNU General Public License (GPL) version 3
# as published by the Free Software Foundation.
#
# ponchon-savarit toolbox is distributed in the hope
# that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# You should have received a copy of the
# GNU General Public License along with this program
# (license GNU GPLv3.txt).
# It is also available at https://www.gnu.org/licenses/.

function [R]=refmin(data,X,q)
    # Syntax:
    #
    # [R]=refmin(data,X,q)
    #
    # refmin computes the minimum value of the reflux ratio
    #  of a distillation column
    #  using the method of Ponchon-Savarit given
    #  a x-h-y-H matrix of the liquid and the vapor fractions
    #  at equilibrium and thier enthalpies,
    #  the vector of the fractions of the distillate and the feed, and
    #  the feed quality.
    # If feed is a saturated liquid, feed quality q = 1,
    #  feed quality is reset to q = 1 - 1e-10.
    #
    # Examples:
    #
    # # Compute the minimum value of the reflux ratio
    # # of a distillation column for oxygen and nitrogen given
    # # a matrix that relates the liquid and the vapor fractions
    # # and their enthalpies at equilibrium,
    # # the composition of the distillate is 88 %,
    # # the composition of the feed is 46 %,
    # # the feed quality is 54 %:
    # data=[ 0.    420 0.    1840;
    #        0.075 418 0.193 1755;
    #        0.17  415 0.359 1685;
    #        0.275 410 0.50  1625;
    #        0.39  398 0.63  1570;
    #        0.525 378 0.75  1515;
    #        0.685 349 0.86  1465;
    #        0.88  300 0.955 1425;
    #        0.1   263 1.    1405];
    # x=[0.88 0.46];
    # q=0.54;
    # r=refmin(data,x,q)
    #
    # # Compute the minimum value of the reflux ratio
    # # of a distillation column for acetone and methanol given
    # # a matrix that relates the liquid and the vapor fractions
    # # and their enthalpies at equilibrium,
    # # the composition of the distillate is 88 %,
    # # the composition of the feed is 46 %,
    # # the feed is a saturated liquid:
    # data=[2.5e-4 3.235 1.675e-3 20.720;
    #       0.05   2.666 0.267    20.520;
    #       0.1    2.527 0.418    20.340;
    #       0.15   2.459 0.517    20.160;
    #       0.2    2.422 0.579    20.000;
    #       0.3    2.384 0.665    19.640;
    #       0.4    2.358 0.729    19.310;
    #       0.5    2.338 0.779    18.970;
    #       0.6    2.320 0.825    18.650;
    #       0.7    2.302 0.87     18.310;
    #       0.8    2.284 0.915    17.980;
    #       0.9    2.266 0.958    17.680;
    #       1      2.250 1        17.390];
    # x=[0.88 0.46 0.08];
    # q=1;
    # r=refmin(data,x,q)
    #
    # See also: stages, qR2S.
    xD=X(1);
    xF=X(2);
    xB=X(3);
    if xD<xF
        error("Inconsistent feed and/or products compositions.");
    end
    if q==1
        q=1-1e-10;
    end
    g=@(x) interp1(data(:,1),data(:,2),x);
    k=@(x) interp1(data(:,3),data(:,4),x);
    foo=@(x) q/(q-1)*x-xF/(q-1);
    bar=@(x) interp1(data(:,1),data(:,3),x)-foo(x);
    x1=bissection(bar,xB,xD);
    h1=g(x1);
    y1=interp1(data(:,1),data(:,3),x1);
    H1=k(y1);
    hliq=g(xD);
    Hvap=k(xD);
    hdelta=(H1-h1)/(y1-x1)*(xD-x1)+h1;
    R=(hdelta-Hvap)/(Hvap-hliq);
end
