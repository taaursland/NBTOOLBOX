classdef nb_graph_ts < nb_graph
% Syntax:
%     
% obj = nb_graph_ts(varargin)
% 
% Superclasses:
% 
% handle, nb_graph
%     
% Description:
%     
% This is a class for making timeseries graphics.
% 
% Constructor:
%     
%     obj = nb_graph_ts(data)
%     
%     Input:
% 
%     - data : The input must one of the following:
% 
%          > An object of class nb_ts. E.g. nb_graph_ts(data)
%
%          > A excel spreadsheet which could be read by the nb_ts 
%            class. E.g. nb_graph_ts('excelName1')
% 
%     It is also possible to initialize an empty nb_graph_ts 
%     object. (Do not provide any inputs to the constructor)
% 
%     Output:
% 
%     - obj : An object of class nb_graph_ts
%     
% See also:
% nb_graph, nb_graph_data, nb_graph_cs, nb_graph_adv, nb_graph_subplot
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    %======================================================================
    % Properties of the class 
    %======================================================================
    properties (SetAccess=protected)
        
        % Sets the end date of the graph. Either as string or an object 
        % which is of a subclass of the nb_date class. If the given date 
        % is after the end date of the data, the data will be appended 
        % with nan values. I.e. the graph will be blank for these dates.        
        endGraph                = nb_date;
        
        % Sets the start date of the graph. Must be a string or an 
        % object which of a subclass of the nb_date class. If this 
        % date is before the start date of the data, the data will be 
        % expanded with nan (blank values) for these periods.        
        startGraph              = nb_date; 
        
    end
    
    properties
        
        % Set this property if you want to plot some average line(s).
        % 
        % Must be given as a cell, i.e. {var,settings, ...}:
        % 
        % > var      : A string with the variable name you want to take 
        %              the average of.
        % 
        % > settings : {'propertyName',propertyValue,...}
        % 
        % The property names options are:
        % 
        % > 'calcStart' : The start date for when to start the 
        %                 calculation of the mean. Default is the 
        %                 date given by the 'startGraph' property.
        % 
        % > 'calcEnd'   : The end date for when to end the 
        %                 calculation of the mean. Default is the 
        %                 date given by the 'endGraph' property.
        % 
        % > 'color'     : Color of the average line. Default is        
        %                 [0 0 0] (MATLAB black).
        % 
        % > 'lineStyle' : Line style of the average line. Default is 
        %                 line style '-'. (Normal line) 
        % 
        % > 'lineWidth' : Line width of the average line. Default 
        %                 line width is 2.5. 
        % 
        % > 'plotStart' : The start date for when to start the 
        %                 plotting of the mean. Default is the 
        %                 date given by the 'startGraph' property.
        % 
        % > 'plotEnd'   : The end date for when to end the 
        %                 plotting of the mean. Default is the 
        %                 date given by the 'endGraph' property.
        % 
        % > 'side'      : The axes side. Either 'left' or 'right'.
        % 
        % If the variable is not found a proper error message will 
        % occur.        
        averageLine             = {};               
        
        % Sets the date from which the bar plot should be shaded. Either 
        % a string or an object which is of a subclass of the nb_date 
        % class.        
        barShadingDate          = nb_date;          
                    
        % Sets how to interpreter the dates. I.e. where to place the 
        % datapoints in relation to the tick mark labels. Must be a 
        % string. {'start'} | 'end' | 'middle'.          
        dateInterpreter         = 'start';          
        
        % All the dates of the plot as a cellstr. Not settable.        
        dates                   = {};               
        
        % Sets the date at which all the plotted lines will be dashed. 
        % Must be given as a string or an object which is of a subclass 
        % of the nb_date class.         
        dashedLine              = nb_date;          
        
        % All the data given to the nb_graph_ts object collected in a 
        % nb_ts object. Should not be set using obj.DB = data! Instead see  
        % the nb_graph_ts.resetDataSource method.                                                    
        DB                      = nb_ts;            
        
        % If a date is given default fans for the one of the variables 
        % 'QSA_GAPNB_Y','QSA_GAP_Y','QUA_DPY_PCPI','QUA_DPY_PCPIJAE',
        % 'QUA_DPY_PCPIXE', 'QUA_DPY_PCPIXE_R' and 'QUA_RNFOLIO' 
        % is added, otherwise not. The frequency of the provided data 
        % must be quarterly (4). Either as a string or an nb_quarter 
        % object. Only one of the aforementioned variables should be 
        % plotted at a time.        
        defaultFans             = nb_date;          
        
        % Dates to plot as a cellstr of dates (strings). Can also use 
        % local variables.
        %
        % This property can be used if you want to compare time
        % observations against eachother. See nb_graph_tsExamples.m
        % for more.
        datesToPlot             = {};        
        
        % Sets the transparency of the fan chart. May be needed if you
        % add fan charts to more than one variable at the time. A number
        % between 0 and 1. 1 is opaque, while 0 is fully transparent.
        fanAlpha                = 1;
        
        % Sets the colors of the fan charts. Must be a matrix of size; 
        % number of fan layer x 3, with the RGB color specifications. 
        % 
        % or
        % 
        % A string with the basis color for the fan colors. Either 
        % 'red', 'blue', 'green', 'yellow', 'magenta', 'cyan' or 
        % 'white'. 
        % 
        % Be aware that the classification of the color of the given 
        % "basecolor" is based on the property fanPercentiles, so if 
        % you have more or less than 4 layers you must change this 
        % property to have the same size as the number of layers. (This 
        % is the case even if you don't use it to calculate the 
        % percentiles of a given datasets. Given by the property 
        % fanDatasets)
        % 
        % Default is the nb colors.
        %
        % Caution: If fanMethod is set to 'graded' the color used are those
        %          assign to the colorMap property.
        fanColor                = 'nb';            
        
        % Sets the data of the added fan layers.
        % 
        % If you have the data of the different layer in separate 
        % datasets. Then the input to this property must be a 2 * number 
        % of layers cell matrix. Can be excel spreadsheets, .mat files 
        % or dyn_ts objects.
        % 
        % or
        % 
        % You can also give the data with all the simulated data or 
        % fan layers in an dyn_ts object or an nb_ts object. (Each page 
        % one simulation or each page one layer). (FASTEST with an nb_ts 
        % object as input.)
        % 
        % Remember that the percentiles for the fan charts is set by the 
        % property  fanPercentiles, default is [.3, .5, .7, .9]. 
        % 
        % The fan layers are added differently given the method you use.
        % 
        % > graph(...): Adds the fan given in this property to the last 
        %               variable given in the property variablesToPlot. 
        %               (If not the fanVariable property is set.) If you 
        %               graph more datasets (in separate figures), the 
        %               fan layers will be the same for all of them. 
        %               Set the fanVariables property if that is not 
        %               wanted.
        % 
        % > graphSubPlots(...): Adds the fan given in this property to  
        %                       the corresponding variable in the last 
        %                       given datasets (last page of the nb_ts 
        %                       object given by the property DB) of each 
        %                       each subplot.
        % 
        % -graphInfoStruct(...): Adds the fan given by this property to 
        %                        each variable of each subplot. Added 
        %                        for the last given dataset. (Last page 
        %                        of the nb_ts object given by the 
        %                        property DB.)        
        fanDatasets             = {};               
        
        % Line width used but the graded fan chart is set to 
        fanGradedLineWidth      = 3;
        
        % Line width used but the graded fan chart is set to 
        fanGradedStyle          = 'line';
        
        % Set this property if you want to add a MPR styled legend 
        % of the fan layers. Set it to 1 if wanted. Default 
        % is not (0).        
        fanLegend               = 0;               
        
        % The file to get the default fan layers from. As a string.
        fanFile                 = '';
        
        % Sets the font size of the fan legend. Default is 12. Must be
        % a scalar.        
        fanLegendFontSize       = 12;

        % Sets the location of the fan legend. Locations are:
        % 
        % > 'Best', (same as 'North'.)
        % > 'NorthWest'
        % > 'North'
        % > 'NorthEast'
        % > 'SouthEast'
        % > 'South'
        % > 'SouthWest'
        % > 'outside'  : Places the legend outside the axes, one the 
        %                right side. (If you create subplots, this is 
        %                the only option which will look good.)
        % 
        % You can also give a 1 x 2 double vector with the location of 
        % where to place the legend. First column is the x-axis location 
        % and the second column is the y-axis location. Both must be 
        % between 0 and 1.        
        fanLegendLocation       = 'outside';        
        
        % Set this property if you want to give the text over the 
        % colored boxes of the MPR looking fan legend, you must give   
        % them as a cell. (Must have same size as number of layers.) 
        % Default is the percentiles with the % sign added. E.g. 
        % {'30%','50%','70%','90%'}.        
        fanLegendText           = {};               
        
        % {'percentiles'} | 'hdi' | 'graded'; Which type of fan chart is 
        % going to be made. 'percentiles' are produced by using 
        % percentiles, 'hdi' use highest density intervals, while 'graded'
        % creates a graded fan chart of the colors specified with the
        % colorMap property.
        fanMethod               = 'percentiles'; 
        
        % Sets the percentiles you want to calculate (if the fanDatasets
        % property is representing simulation) or specify the 
        % percentiles you have given (if the fanDatasets property is 
        % representing already calculated percentiles). Must be given as 
        % a double vector. Default is [0.3 0.5 0.7 0.9]. 
        % 
        % This property is also the default base for the text of the 
        % fan legend. (Where the percentiles are given in percent.)        
        fanPercentiles          = [.3,.5,.7,.9];    
        
        % Sets the variable you want to add the fan layers to. Must be 
        % given as a string with the variable name. Default is to use 
        % the last variable in the variablesToPlot property.   
        %
        % If this input is a cellstr with more than one variable, the 
        % 'fanPercentiles' input must be a scalar double. Fan chart will
        % then be added to more than one variable.
        fanVariable             = '';         
        
        % If you have the fan layers included in the same dataset as 
        % your other plotted variables you can use this property. The 
        % input must then be given as 1 x 2 * number of layers cell array 
        % with the fan layers names (as strings). I.e. both the upper 
        % and lower layers must be given as separate variables. 
        % (Need not be ordered though.) 
        %
        % E.g. {'LowPerc 90%','LowPerc 70%','UppPerc 90%','UppPerc 70%'}
        % 
        % Caution: Must fit the number of percentiles given by the property
        %          fanPercentiles (Remember to include both upper and lower
        %          bounds!).
        %
        % Only an input to the method graph(...): Adds the given fan 
        % layers to the last variable given by the property 
        % variablesToPlot or the variable given by fanVariable property.                                                    
        fanVariables            = {};                             
          
        % If highlighted area between two dates of the graph is wanted 
        % set this property.
        % 
        % One highlighted area: 
        % A cell array on the form {'date1', 'date2'}
        % 
        % More highlighted areas: 
        % A nested cell array on the form 
        % {{'date1(1)', 'date2(1)'},{'date1(2)', 'date2(2)'},...} 
        %
        % If plotType is set to 'scatter' scalars can be used 
        % instead. 
        highlight               = {}; 
        
        % Sets the colors of the background patches. Must be on of the 
        % following:
        % 
        % > A string with the color name to use when plotting (all) the 
        %   patch(es) 
        % > A cell array of strings with the color names 
        % > A cell with 1 x 3 doubles with the RGB color specification. 
        % 
        % When given as a cell this property must match the highlight 
        % property. I.e. the number of highlighted areas added.  
        % 
        % The default color of the highlighted areas is 'light blue'.        
        highlightColor          = {}; 
        
        % Set how to interpret missing observations. Must be a string.
        % Either;
        % 
        % > 'interpolate' : Linearly interpolate the missing values.
        % 
        % > 'strip'       : Strip the missing values. Should only be 
        %                   used with business days data.
        % 
        % > 'both'        : First strip up until a date given by the 
        %                   property stopStrip and then interpolate the 
        %                   rest of the missing values. If the stopStrip 
        %                   property is not given this will result in 
        %                   the same as the 'strip' option.
        % %
        % > 'none'        : No interpolation (default)
        missingValues           = 'none';           
        
        % Sets the max/min y-axis limits of the plot. Must be 1 x 2 double 
        % vector, where the first number is the lower limit and the 
        % second number is the upper limit. (Both or one of them can be  
        % set to nan, i.e. the default limits will be used) E.g. [0 6],
        % [nan, 6] or [0, nan].
        % 
        % Caution: If the variablesToPlotRight property is not empty 
        %          this setting only sets the left y-axis limits. 
        % 
        % Only an option for the graphInfoStruct(...) method. 
        mYLim                   = [];               
        
        % If setted this property would make the graph blank after the 
        % provided date, but the x-axis would still keeps its axis 
        % limits. Must be a string with the date or an object which of
        % a subclass of the nb_date class.        
        nanAfterDate            = '';               
        
        % If setted this property would make the graph blank before the 
        % provided date, but the x-axis would still keeps its axis 
        % limits. Must be a string with the date or an object which of
        % a subclass of the nb_date class.        
        nanBeforeDate           = '';               
        
        % Sets the nan option for individual variables. Must be given 
        % as a cell. I.e. {'var1', {'2012Q2', '2012Q4'}, ...
        % 'var2', {'2012Q2', '2012Q4'},...}. This will make both 'var1' 
        % and 'var2' variables blank before '2012Q2' and after '2012Q4' 
        % (Not including.) in the given graph.        
        nanVariables            = {};                    
                     
        % Sets the plot type. Either:
        % 
        % > 'line'        : If line plot(s) is wanted. Default. 
        % 
        % > 'stacked'     : If stacked bar plot(s) is wanted. Not an 
        %                 option for the graphSubPlots(...) method. 
        % 
        % > 'grouped'     : If grouped bar plot(s) is wanted. 
        % 
        % > 'dec'         : If decomposition plot(s) is wanted. Which is 
        %                 a bar plot with also a line with the sum of 
        %                 the stacked bars. Not an option for the
        %                 graphSubPlots(...) method.
        % 
        % > 'area'        : If area plot(s) is wanted.
        % 
        % > 'candle'      : If candle plot(s) is wanted.
        % 
        % > 'scatter'     : If scatter plot(s) is wanted.
        % 
        % > 'simpleRules' : Can be given if you want graph of the 
        %                   interest rate path compared with the 
        %                   simple rules. (MPR looking graph.) The 
        %                   different variables must have the names:
        % 
        %                   'QUA_RNFOLIO'       : Interest rate path.
        %                   'QUA_TAYLOR'        : Taylor-rule.
        %                   'QUA_GROWTHRULE'    : Uses a growth gap 
        %                                         measure instead of the 
        %                                         output gap in the 
        %                                         simple rule.
        %                   'QUA_FOREIGNRULE'   : A simple rule that 
        %                                         takes foreign 
        %                                         variables into account
        %                   'QUA_MODELBASEDRULE': A simple rule base on 
        %                                         some work of FA. A 
        %                                         rule which is robust 
        %                                         in different models.
        % 
        %                   You can set which simple rules you want to 
        %                   plot with the  property simpleRules and you 
        %                   can graph two different versions of the 
        %                   simple rules using the 
        %                   simpleRulesSecondData property.
        % 
        %                   Only an option for the graph(...) method.        
        plotType                = 'line';           
        
        % Sets the plot type of the given variables. Must be a cell 
        % array on the form: {'var1', 'line', 'var2', 'grouped',...}. 
        % Here we set the plot type of the variables 'var1' and 'var2' 
        % to 'line' and 'grouped' respectively. The variables given 
        % must be included in the variablesToPlot or 
        % variablesToPlotRight properties.
        % 
        % See the property plotType above on which plot types that are 
        % supported.        
        plotTypes               = {};               

        %   Sets the start and end to be used for the scatter plot plotted  
        %   against the left axes. Must be a nested cell array. The dates 
        %   can be given as strings or date objects. E.g:
        %
        %   {'scatterGroup1',{'startDate1','endDate1'},...
        %    'scatterGroup2',{'startDate2','endDate2'},...}
        %
        %   Caution  : This property must be provided to produce
        %              a scatter plot! (Or of course scatterDatesRight)
        %
        %   Be aware : Each date will result in one point in the 
        %              scatter.
        scatterDates            = {};
        
        %   Sets the start and end to be used for the scatter plot plotted  
        %   against the right axes. Must be a nested cell array. The dates 
        %   can be given as strings or date objects. E.g:
        %
        %   {'scatterGroup1',{'startDate1','endDate1'},...
        %    'scatterGroup2',{'startDate2','endDate2'},...}
        %
        %   Caution  : This property must be provided to produce
        %              a scatter plot! (Or of course scatterDates)
        %
        %   Be aware : Each date will result in one point in the 
        %              scatter.
        scatterDatesRight       = {};

        % Sets the scatter line style. Must be string. See 'lineStyles'
        % for supported inputs. (Sets the line style of all scatter plots)
        scatterLineStyle        = 'none';
        
        %   The variables used for the scatter plot. Must be a 1x2 cellstr 
        %   array. The first element will be the variable plotted against 
        %   the x-axis, while the second element will be the variable 
        %   plotted against the left y-axis. E.g:
        %
        %   {'var1','var2'}
        scatterVariables        = {};

        %   The variables used for the scatter plot. Must be a 1x2 cellstr 
        %   array. The first element will be the variable plotted against 
        %   the x-axis, while the second element will be the variable 
        %   plotted against the right y-axis. E.g:
        %
        %   {'var1','var2'}
        scatterVariablesRight   = {};

        % Sets the simple rules which will be graphed by the method 
        % graph(...) when the plotType property is set to 'simpleRules'. 
        % Must be a cell array of strings. See the documentation on the 
        % property plotType for more on the simple rules to include.
        simpleRules             = {};               
        
        % Sets the data of an older version of the simple rules. Only an 
        % option of the method graph(...) when the plotType property is 
        % set to 'simpleRules'. Must be a string with the name of a 
        % excel spreadsheet, a dyn_ts object or an nb_ts object. 
        % (.mat file is not supported.) Must include the variables given 
        % below (or the variables given by the 'simpleRules' property.):
        % 
        % > 'QUA_TAYLOR'         : Taylor-rule.
        % > 'QUA_GROWTHRULE'     : Uses a growth gap measure instead of 
        %                          the output gap in the simple rule.
        % > 'QUA_FOREIGNRULE'    : A simple rule that takes foreign 
        %                          variables into account.
        % > 'QUA_MODELBASEDRULE' : A simple rule base on some work of 
        %                          FA. A rule which is robust in 
        %                          different models.        
        simpleRulesSecondData   = nb_ts;            
        
        % Sets the x-ticks spacing. Must be a scalar. Refers to the 
        % given x-axis tick frequency.      
        spacing                 = [];               
        
        % Sets the stop date of the graph. Must be a string or an 
        % object which of a subclass of the nb_date class.        
        stopStrip               = nb_date;               
        
        % Sets a time for when to stop updating the data of this graph,
        % i.e. if the actual time has past this date the data will not be
        % updated. Must be a string on the format 'yyyymmdd', 
        % 'yyyymmddhh' or 'yyyymmddhhmm'. E.g. '20121010', '2012101010'
        % or '201210101000'. 
        %
        % Caution: No warning will be provided!
        stopUpdate              = ''; 
        
        % Use this property to set subplot spesific options of each
        % variable while using the the method graphSubPlots(). Each
        % field must be the name of the variable. The options are:
        %
        % - yLabel     : The y-axis label.
        % - yLim       : Sets the y-axis limits. As a 1x2 double.
        % - ySpacing   : Spacing between y-axis tick marks.
        % - dashedLine : The date to start the dashed line for the given
        %                variable.
        %
        % Example:
        % s.Var1 = struct('yLim',[0,1]);
        % s.Var2 = struct('yLim',[0,1]);
        subPlotsOptions         = struct();
        
        % Sets the date(s) of where to place a vertical line(s). 
        % (Dotted orange line is default). Must be a string or a cell 
        % array of strings with the date(s) for where to place the 
        % vertical line(s). I.e. 'date1' or {'date1','date2',...} 
        % 
        % Each element of the cell could also be given as a cell with 
        % two dates, i.e. {'date1', 'date2' }. Then the vertical line 
        % will be placed between the given dates.   
        %
        % If plotType is set to 'scatter' scalars can be used 
        % instead. 
        verticalLine            = {};              
        
        % Sets the color(s) of the given vertical line(s). Must either 
        % be an M x 3 double with the RGB color(s) or a 1 x M cell array 
        % of strings with the color name(s). Where M must be less than 
        % the number of plotted vertical lines. 
        % 
        % If less or no color(s) is/are set by this property the default 
        % color(s) for the rest or all the vertical line(s) is/are 
        % [0 0 0]. I.e. MATLAB black.        
        verticalLineColor       = {};               
        
        % Sets the y-axis limit(s) of the given vertical line(s). Must 
        % either be a 1 x M cell array of 1 x 2 double with the upper 
        % and lower y-axis limit(s). Where M must be less than the 
        % number of plotted vertical lines. 
        % 
        % If less or no limit(s) is/are set by this property the default 
        % limit for the rest or all the vertical line(s) is/are the full 
        % height of the graph.        
        verticalLineLimit       = {};               
        
        % Sets the line style(s) of the given vertical line(s). Must 
        % either be a 1 x M cell array of strings with the style(s). 
        % Where M must be less than the number of plotted vertical 
        % lines. 
        % 
        % If less or no style(s) is/are set by this property the default 
        % line style is/are used for the rest or all the vertical 
        % line(s) is/are '--'.        
        verticalLineStyle       = {'--'};             
        
        % Sets the line width of (all) the vertical line(s). Must be a 
        % scalar. Default is 1.5.        
        verticalLineWidth       = 1.5;              
             
        % Sets the x-axis limits of the plot. Must be 1 x 2 double 
        % vector, where the first number is the lower limit and the 
        % second number is the upper limit. (Both or one of them can be  
        % set to nan, i.e. the default limits will be used) E.g. [0 6],
        % [nan, 6] or [0, nan].
        % 
        % Only an option when the plotType property is set to 'scatter'.
        xLim                    = [];

        % Sets the scale of the x-axis. Either {'linear'} | 'log'.
        %
        % Only an option when plotType is set to 'scatter'.
        xScale                  = 'linear'; 
        
        % Sets the frequency of the x-axis tick mark labels. Only 
        % necessary if the wanted frequency differs from the data 
        % plotted. Must be a string. One of the following
        % 
        % > 'yearly' 
        % > 'semiannually'
        % > 'quarterly'
        % > 'monthly'
        % > 'weekly'
        % > 'daily'
        % 
        % Caution : It is only possible to use an frequency which is 
        %           lower then the frequency of the data.
        % 
        % Caution : When the data are of a daily frequency the default 
        %           is to set the xTickFrequency to 'yearly'.        
        xTickFrequency          = '';              
        

        % The location of the x-axis tick marks labels. Either  
        % {'bottom'} | 'top' | 'baseline'. 'basline' will only work in 
        % combination with the xtickLocation property set to a double
        % with the basevalue.        
        xTickLabelLocation      = 'bottom'; 

        % The alignment of the x-axis tick marks labels. {'normal'} | 
        % 'middle'.        
        xTickLabelAlignment     = 'normal';

        % The location of the x-axis tick marks. Either {'bottom'} | 
        % 'top' | double. If given as a double the tick marks will be 
        % placed at this value (where the number represent the y-axis
        % value).
        xTickLocation           = 'bottom'; 

        % Sets the rotation of the x-axis tick mark labels. Must be a 
        % scalar with the number of degrees the labels should be 
        % rotated. Positive angles cause counterclockwise rotation.        
        xTickRotation           = 0;            
        
        % Sets the start date of where to start the x-tick mark labels.
        % Must be a string or an object which of a subclass of the 
        % nb_date class.       
        xTickStart              = '';                   
        
        % Sets the direction of the y-axis of the plot. Must be a 
        % string. Either 'normal' or 'reverse'. Default is 'normal'.
        % 
        % Caution: If the variablesToPlotRight is not empty this setting 
        %          only sets the left y-axis direction.        
        yDir                    = 'normal';         
        
        % Sets the direction of the right y-axis of the plot. Either 
        % 'normal' or 'reverse'. Default is 'normal'. (Only when the 
        % variablesToPlotRight property is not empty.)        
        yDirRight               = 'normal';         
        
        % Sets the y-axis limits of the plot. Must be 1 x 2 double 
        % vector, where the first number is the lower limit and the 
        % second number is the upper limit. (Both or one of them can be  
        % set to nan, i.e. the default limits will be used) E.g. [0 6],
        % [nan, 6] or [0, nan].
        % 
        % Caution: If the variablesToPlotRight property is not empty 
        %          this setting only sets the left y-axis limits. 
        % 
        % Only an option for the graph(...) and graphSubPlots() methods.  
        % (For the graphInfoStruct(...) method use the property 
        % GraphStruct.)
        yLim                    = [];               
        
        % Sets the right y-axis limits of the plot. Must be 1 x 2 double 
        % vector, where the first number is the lower limit and the 
        % second number is the upper limit. (Only when the 
        % variablesToPlotRight property is not empty.) (Both or one of 
        % them can be set to nan, i.e. the default limits will be used) 
        % E.g. [0 6], [nan, 6] or [0, nan].
        % 
        % Only an option for the graph(...) and graphSubPlots() methods.  
        % (For the graphInfoStruct(...) method use the property 
        % GraphStruct.)           
        yLimRight               = [];  
        
        % The y-axis tick mark labels offset from the axes  
        yOffset                 = 0.01;                   
        
        % Sets the scale of the y-axis. {'linear'} | 'log'.(Both  
        % the left and the right axes if nothing is plotted on the 
        % right axes.)
        yScale                  = 'linear';
        
        % Sets the scale of the right y-axis. {'linear'} | 'log'.  
        % (Has only somthing to say if somthing is plotted on the 
        % right axes)
        yScaleRight             = 'linear';
        
        % Sets the spacing between y-axis tick mark labels of the 
        % y-axis. Must be scalar. 
        % 
        % Caution: The spacing will be the number of periods between the
        %          tick marks labels. The number of periods will follow 
        %          the frequency of the xTickFrequency property if 
        %          setted, else it will  follow the frequency of the 
        %          data provided. (Except when dealing with daily data, 
        %          because then the default xTickFrequency is 'yearly')
        % 
        % Caution: If the variablesToPlotRight property is not empty 
        %          this property only sets the spacing between ticks of 
        %          the left y-axis.    
        ySpacing                = [];               
        
        % Sets the spacing between y-axis tick mark labels of the 
        % right y-axis. Must be scalar. 
        % 
        % Caution: The spacing will be the number of periods between the
        %          tick marks labels. The number of periods will follow 
        ySpacingRight           = [];               

    end 
    
    %======================================================================
    % Protected properties 
    %======================================================================
    properties (Access=protected)
        
        alreadyAdjusted             = 0;                % An indicator of font size beeing adjusted. 
        datesOfGraph                = {};               % X-tick dates of graph. Not settable.  
        fanData                     = [];               % A property which temporary stores the data for fan charts
        fanVariableIndex            = [];               % Not settable. 
        manuallySetEndGraph         = 0;                % Indicator if the endGraph property has been set manually
        manuallySetStartGraph       = 0;                % Indicator if the startGraph property has been set manually
              
    end
    
    %======================================================================
    % Methods of the class 
    %======================================================================
    methods
        
        function obj = nb_graph_ts(varargin)
            
            obj = obj@nb_graph;
            
            if nargin ~= 0 % Makes it possible to initilize an empty object
                
                if nargin == 1
                    switch class(varargin{1})
                        case 'nb_ts'
                            obj.DB = varargin{1};
                        case 'char'              
                            obj.DB = nb_ts(varargin{1});
                        otherwise
                            error([mfilename ':: The input to this function must be a object of class nb_ts or string.'])
                    end
                else
                    error('nb_graph_ts takes only one input') 
                end
                     
                % Set some default properties
                obj.startGraph      = obj.DB.startDate;
                obj.endGraph        = obj.DB.endDate;
                obj.variablesToPlot = obj.DB.variables;
                obj.localVariables  = obj.DB.localVariables;
                
            end
                
        end
        
        function setSpecial(obj,varargin)
        % Undocumented function to set properties which are 
        % protected 
            
            if size(varargin,1) && iscell(varargin{1})
                % Makes it possible to give options directly through a cell
                varargin = varargin{1};
            end

            for jj = 1:2:size(varargin,2)

                propertyName  = varargin{jj};
                propertyValue = varargin{jj + 1};

                if ischar(propertyName)

                    switch lower(propertyName)
                        
                        case 'advanced'
                            obj.advanced = propertyValue;   
                        case 'axeshandle'
                            obj.axesHandle = propertyValue;
                        case 'db'
                            obj.DB = propertyValue;
                        case 'defaultfigurenumbering'
                            obj.defaultFigureNumbering = propertyValue;
                        case 'figurehandle'
                            obj.figureHandle = propertyValue;
                            if isempty(propertyValue)
                                obj.manuallySetFigureHandle = 0;
                            else
                                obj.manuallySetFigureHandle = 1;
                            end
                        case 'figtitleobjecteng'
                            
                            obj.figTitleObjectEng = propertyValue;
                            
                        case 'figtitleobjectnor'
                            obj.figTitleObjectNor = propertyValue;
                        case 'footerobjecteng' 
                            obj.footerObjectEng = propertyValue;
                        case 'footerobjectnor'
                            obj.footerObjectNor = propertyValue;
                        case 'fontunits'
                            oldFontSize   = obj.fontUnits;
                            obj.fontUnits = propertyValue;
                            setFontSize(obj,oldFontSize);
                        case 'graphmethod' 
                            obj.graphMethod = propertyValue;
                        case 'localvariables'
                            % Set local variables without testing
                            obj.localVariables    = propertyValue;
                            obj.DB.localVariables = propertyValue; 
                        case 'manuallysetendgraph'   
                            obj.manuallySetEndGraph = propertyValue;
                        case 'manuallysetstartgraph'  
                            obj.manuallySetStartGraph = propertyValue;
                        case 'plotaspectratio'
                            obj.plotAspectRatio = propertyValue;
                        case 'returnlocal'  
                            obj.returnLocal = propertyValue;   
                        case 'uicontextmenu'
                            obj.UIContextMenu = propertyValue;
                        case 'variablestoplot' 
                            obj.variablesToPlot = propertyValue;
                        otherwise 
                            error([mfilename ':: The class nb_graph_ts has no property ''' propertyName ''' or you have no access to set it.'])
                    end

                end
                
            end

        end
        
        function disp(obj)
            
            link = nb_createLinkToClass(obj);
            disp([link, ' with:'])
            disp(['   <a href="matlab: nb_graph.dispMethods(''' class(obj) ''')">Methods</a>']);
            
            groups = {
                'Annotation properties:',   {'highlight','highlightColor','verticalLine','verticalLineColor',...
                                             'verticalLineLimit','verticalLineStyle','verticalLineWidth'}
                'Axes properties:',         {'dateInterpreter','dates','endGraph','mYLim','startGraph','spacing',...
                                             'xLim','xScale','xTickFrequency','xTickLabelLocation','xTickLabelAlignment',...
                                             'xTickLocation','xTickRotation','xTickStart','yDir','yDirRight','yLim',...
                                             'yLimRight','yOffset','yScale','yScaleRight','ySpacing','ySpacingRight'}
                'Data properties:',         {'DB','stopUpdate'}
                'Fan chart properties:',    {'defaultFans','fanAlpha','fanColor','fanDatasets','fanGradedLineWidth'...
                                             'fanGradedStyle','fanLegend','fanFile','fanLegendFontSize',...
                                             'fanLegendLocation','fanLegendText','fanMethod','fanPercentiles',...
                                             'fanVariable','fanVariables'}
                'Missing data properties:', {'missingValues','nanAfterDate','nanBeforeDate','nanVariables','stopStrip'}                             
                'Plot properties:',         {'averageLine','barShadingDate','dashedLine','datesToPlot','plotType',...
                                             'plotTypes'} 
                'Scatter plot properties:', {'scatterDates','scatterDatesRight','scatterLineStyle','scatterVariables',...
                                             'scatterVariablesRight'}                       
            };
            groups = nb_graph.mergeDispTables(groups,nb_graph.dispTableGeneric());
            remove = {'numberOfGraphs'};
            type   = 'properties';
            disp(nb_createDispTable(obj,groups,remove,type));
            
        end
        
        varargout = get(varargin)        
        varargout = graph(varargin)       
        varargout = graphSubPlots(varargin)       
        varargout = graphInfoStruct(varargin)       
        varargout = timespan(varargin)       
        varargout = update(varargin)      
        varargout = saveData(varargin)
        
        %==========================================================
        % Overloaded get methods (So it is robust to locally
        % defined variables)
        %==========================================================
        
        function out = get.barShadingDate(obj)
            
            if ischar(obj.barShadingDate) && ~obj.returnLocal
                
                ind = strfind(obj.barShadingDate,'%#');
                if isempty(ind)
                    out = nb_date.toDate(obj.barShadingDate,obj.DB.frequency);
                else
                    if isstruct(obj.localVariables)
                        out = nb_localVariables(obj.localVariables,obj.barShadingDate);
                    else
                        error('nb_graph:LocalVariableError',[mfilename ':: No local variables defined, so the syntax %%# cannot be used.'])
                    end
                    try
                        out = nb_date.toDate(out,obj.DB.frequency);
                    catch
                        error('nb_graph:LocalVariableError',[mfilename ':: Unsupported date %' out ' for frequency ' nb_date.getFrequencyAsString(obj.DB.frequency) ...
                                         ' given to the property barShadingDate with local variable notation.'])
                    end
                end
                
            elseif iscell(obj.barShadingDate) && ~obj.returnLocal
                
                out = obj.barShadingDate;
                for ii = 2:2:length(obj.barShadingDate)
                
                    if ischar(obj.barShadingDate{ii})
                    
                        ind = strfind(obj.barShadingDate{ii},'%#');
                        if isempty(ind)
                            out{ii} = nb_date.toDate(obj.barShadingDate{ii},obj.DB.frequency);
                        else
                            if isstruct(obj.localVariables)
                                out{ii} = nb_localVariables(obj.localVariables,obj.barShadingDate{ii});
                            else
                                error('nb_graph:LocalVariableError',[mfilename ':: No local variables defined, so the syntax %%# cannot be used.'])
                            end
                            try
                                out{ii} = nb_date.toDate(out{ii},obj.DB.frequency);
                            catch
                                error('nb_graph:LocalVariableError',[mfilename ':: Unsupported date %' out ' for frequency ' nb_date.getFrequencyAsString(obj.DB.frequency) ...
                                                 ' given to the property barShadingDate with local variable notation.'])
                            end
                        end
                        
                    end
                
                end
                    
            else
                out = obj.barShadingDate;
            end
            
        end
        
        function out = get.defaultFans(obj)
            
            if ischar(obj.defaultFans) && ~obj.returnLocal
                ind = strfind(obj.defaultFans,'%#');
                if isempty(ind)
                    out = nb_date.toDate(obj.defaultFans,obj.DB.frequency);
                else
                    if isstruct(obj.localVariables)
                        out = nb_localVariables(obj.localVariables,obj.defaultFans);
                    else
                        error('nb_graph:LocalVariableError',[mfilename ':: No local variables defined, so the syntax %%# cannot be used.'])
                    end
                    try
                        out = nb_date.toDate(out,obj.DB.frequency);
                    catch
                        error('nb_graph:LocalVariableError',[mfilename ':: Unsupported date %' out ' for frequency ' nb_date.getFrequencyAsString(obj.DB.frequency) ...
                                         ' given to the property defaultFans with local variable notation.'])
                    end
                end
            else
                out = obj.defaultFans;
            end
            
        end
        
        function out = get.dashedLine(obj)
            
            if ischar(obj.dashedLine) && ~obj.returnLocal
                ind = strfind(obj.dashedLine,'%#');
                if isempty(ind)
                    out = nb_date.toDate(obj.dashedLine,obj.DB.frequency);
                else
                    if isstruct(obj.localVariables)
                        out = nb_localVariables(obj.localVariables,obj.dashedLine);
                    else
                        error('nb_graph:LocalVariableError',[mfilename ':: No local variables defined, so the syntax %%# cannot be used.'])
                    end
                    try
                        out = nb_date.toDate(out,obj.DB.frequency);
                    catch
                        error('nb_graph:LocalVariableError',[mfilename ':: Unsupported date %' out ' for frequency ' nb_date.getFrequencyAsString(obj.DB.frequency) ...
                                         ' given to the property dashedLine with local variable notation.'])
                    end
                end
            else
                out = obj.dashedLine;
            end
            
        end
        
        function out = get.endGraph(obj)
            
            if ~obj.manuallySetEndGraph && ~isempty(obj.DB)
                vars = getPlottedVariables(obj);
                out  = obj.DB.getRealEndDate('nb_date','any',vars);
                if isempty(out)
                   out = obj.DB.endDate; 
                end
            elseif ischar(obj.endGraph) && ~obj.returnLocal
                ind = strfind(obj.endGraph,'%#');
                if isempty(ind)
                    out = nb_date.toDate(obj.endGraph,obj.DB.frequency);
                else
                    if isstruct(obj.localVariables)
                        out = nb_localVariables(obj.localVariables,obj.endGraph);
                    else
                        error('nb_graph:LocalVariableError',[mfilename ':: No local variables defined, so the syntax %%# cannot be used.'])
                    end    
                    try
                        out = nb_date.toDate(out,obj.DB.frequency);
                    catch
                        error('nb_graph:LocalVariableError',[mfilename ':: Unsupported date %' out ' for frequency ' nb_date.getFrequencyAsString(obj.DB.frequency) ...
                                         ' given to the property endGraph with local variable notation.'])
                    end
                end
            else
                out = obj.endGraph;
            end
            
        end
        
        function out = get.startGraph(obj) 
            
            if ~obj.manuallySetStartGraph && ~isempty(obj.DB)
                out  = obj.DB.getRealStartDate('nb_date');
                if isempty(out)
                   out = obj.DB.startDate; 
                end
            elseif ischar(obj.startGraph) && ~obj.returnLocal
                ind = strfind(obj.startGraph,'%#');
                if isempty(ind)
                    out = nb_date.toDate(obj.startGraph,obj.DB.frequency);
                else
                    if isstruct(obj.localVariables)
                        out = nb_localVariables(obj.localVariables,obj.startGraph);
                    else
                        error('nb_graph:LocalVariableError',[mfilename ':: No local variables defined, so the syntax %%# cannot be used.'])
                    end    
                    try
                        out = nb_date.toDate(out,obj.DB.frequency);
                    catch
                        error('nb_graph:LocalVariableError',[mfilename ':: Unsupported date %' out ' for frequency ' nb_date.getFrequencyAsString(obj.DB.frequency) ...
                                         ' given to the property startGraph with local variable notation.'])
                    end
                end
            else
                out = obj.startGraph;
            end
            
        end
        
        function out = get.stopStrip(obj)
            
            if ischar(obj.stopStrip) && ~obj.returnLocal
                ind = strfind(obj.stopStrip,'%#');
                if isempty(ind)
                    out = nb_date.toDate(obj.stopStrip,obj.DB.frequency);
                else
                    if isstruct(obj.localVariables)
                        out = nb_localVariables(obj.localVariables,obj.stopStrip);
                    else
                        error('nb_graph:LocalVariableError',[mfilename ':: No local variables defined, so the syntax %%# cannot be used.'])
                    end    
                    try
                        out = nb_date.toDate(out,obj.DB.frequency);
                    catch
                        error('nb_graph:LocalVariableError',[mfilename ':: Unsupported date %' out ' for frequency ' nb_date.getFrequencyAsString(obj.DB.frequency) ...
                                         ' given to the property stopStrip with local variable notation.'])
                    end
                end
            else
                out = obj.stopStrip;
            end
            
        end
        
        function out = get.stopUpdate(obj)
            
            if isempty(obj.stopUpdate)
                out = '';
                return
            end
            
            local = false;
            if ischar(obj.stopUpdate) && ~obj.returnLocal          
                ind   = strfind(obj.stopUpdate,'%#');
                local = ~isempty(ind);
                if ~local
                    out = obj.stopUpdate;
                else
                    if isstruct(obj.localVariables)
                        out = nb_localVariables(obj.localVariables,obj.stopUpdate);
                    else
                        error('nb_graph:LocalVariableError',[mfilename ':: No local variables defined, so the syntax %%# cannot be used.'])
                    end    
                end
            else
                out = obj.stopUpdate;
            end
            
            if ~ischar(out)
                throwErrorStopUpdate(obj,local)
            end
            
            if nb_sizeEqual(out,[1,8])
                out = [out, '2359'];
            elseif nb_sizeEqual(out,[1,10])
                out = [out, '59'];     
            elseif ~nb_sizeEqual(out,[1,12])
                throwErrorStopUpdate(obj,local)
            end
            
            test = str2double(out);
            if isnan(test)
                throwErrorStopUpdate(obj,local)
            end
            
            function throwErrorStopUpdate(obj,local)
               
                if local
                    error('nb_graph:LocalVariableError',[mfilename ':: The local variable %' obj.stopUpdate ' given to the ''stopUpdate'' property must be a string '...
                          'on the format ''yyyymmdd'', ''yyyymmddhh'' or ''yyyymmddhhmm''.'])
                else
                    error([mfilename ':: The ''stopUpdate'' property must be set to a string on the format ''yyyymmdd'', ''yyyymmddhh'' or ''yyyymmddhhmm''.'])
                end
                
            end
            
        end
        
        function out = get.xTickStart(obj) 
            
            if ischar(obj.xTickStart) && ~obj.returnLocal
                
                if ~isempty(obj.xTickFrequency)
                    freq = nb_date.getFrequencyAsInteger(obj.xTickFrequency);
                else
                    freq = obj.DB.frequency;
                end
                
                ind = strfind(obj.xTickStart,'%#');
                if isempty(ind)
                    out = nb_date.toDate(obj.xTickStart,freq);
                else
                    if isstruct(obj.localVariables)
                        out = nb_localVariables(obj.localVariables,obj.xTickStart);
                    else
                        error('nb_graph:LocalVariableError',[mfilename ':: No local variables defined, so the syntax %%# cannot be used.'])
                    end    
                    try
                        out = nb_date.toDate(out,freq);
                    catch
                        error('nb_graph:LocalVariableError',[mfilename ':: Unsupported date %' out ' for frequency ' nb_date.getFrequencyAsString(obj.DB.frequency) ...
                                         ' given to the property xTickStart with local variable notation.'])
                    end
                end
            else
                out = obj.xTickStart;
            end
            
        end
         
    end
    
    methods (Access=public,Hidden=true)
        
        function s = saveobj(obj)
        % Overload how the object is saved to a .MAT file
        
            s = struct(obj);
        
        end
        
        function fanChartGUI(obj,~,~,type)
        % Fan chart GUI    

            if isempty(obj.DB)
                nb_errorWindow('No properties can be set, because the data of the graph is empty.')
                return
            end
        
            % Make GUI
            gui = nb_fanChartGUI(obj,type);
            addlistener(gui,'changedGraph',@obj.graphUpdate);

        end
        
        function fanLegendGUI(obj,~,~)
        % Fan legend GUI    

            if isempty(obj.DB)
                nb_errorWindow('No properties can be set, because the data of the graph is empty.')
                return
            end
        
            % Make GUI
            gui = nb_fanLegendGUI(obj);
            addlistener(gui,'changedGraph',@obj.graphUpdate);

        end
        
         function spreadsheetFanDataGUI(obj,~,~)
        % Create simple spreadsheet of data behind figure    

            if isempty(obj.fanDatasets)
                nb_errorWindow('The fan data of the graph is empty and cannot be displayed.')
                return
            end
            nb_spreadsheetSimpleGUI(obj.parent,obj.fanDatasets);

        end
        
        function removeObservationsGUI(obj,~,~)
        % Fan chart GUI    

            if isempty(obj.DB)
                nb_errorWindow('No properties can be set, because the data of the graph is empty.')
                return
            end
            gui = nb_removeObservationsGUI(obj);
            addlistener(gui,'changedGraph',@obj.graphUpdate);

        end
        
        function datesToPlotGUI(obj,~,~)
        % Fan chart GUI    

            if isempty(obj.DB)
                nb_errorWindow('No properties can be set, because the data of the graph is empty.')
                return
            end
            gui = nb_datesToPlotGUI(obj);
            addlistener(gui,'changedGraph',@obj.graphUpdate);
            addlistener(gui,'changedGraphType',@obj.graphStyleUpdate);

        end
        
        function stopUpdateGUI(obj,~,~)
            
            if isempty(obj.DB)
                nb_errorWindow('No properties can be set, because the data of the graph is empty.')
                return
            end
            gui = nb_stopUpdateGUI(obj);
            addlistener(gui,'changedGraph',@obj.graphUpdate);
            
        end
        
        function addDefaultContextMenu(obj)
        % Adds default context menu to the graphs axes 
            
            obj.UIContextMenu = uicontextmenu();
            graphMenu         = uimenu(obj.UIContextMenu,'Label','Graph');
            dataMenu          = uimenu(obj.UIContextMenu,'Label','Data');
            propertiesMenu    = uimenu(obj.UIContextMenu,'Label','Properties');
            annotationMenu    = uimenu(obj.UIContextMenu,'Label','Annotation');
            addMenuComponents(obj,graphMenu,dataMenu,propertiesMenu,annotationMenu);
              
        end
        
        function addMenuComponents(obj,graphMenu,dataMenu,propertiesMenu,annotationMenu)
            
            if ~isempty(graphMenu)
                uimenu(graphMenu,'Label','Notes','separator','on','Callback',@obj.editNotes);
            end
            
            if ~isempty(dataMenu)
                uimenu(dataMenu,'Label','Page','Callback',@obj.setPageGUI);
                uimenu(dataMenu,'Label','Spreadsheet','Callback',@obj.spreadsheetGUI);
                uimenu(dataMenu,'Label','Spreadsheet Fan Data','Callback',@obj.spreadsheetFanDataGUI);
                uimenu(dataMenu,'Label','Update','separator','on','Callback',@obj.updateGUI);
                uimenu(dataMenu,'Label','Stop Update','Callback',@obj.stopUpdateGUI);
            end
            
            uimenu(propertiesMenu,'Label','Plot type','Callback',@obj.selectPlotTypeGUI);
            uimenu(propertiesMenu,'Label','Select variable','tag','changeWhenDatesVsDates','Callback',@obj.selectVariableGUI);
            reorderM = uimenu(propertiesMenu,'Label','Reorder','tag','reorderMenu');
                uimenu(reorderM,'Label','Left axes variables','Callback',{@obj.reorderGUI,'left'});
                uimenu(reorderM,'Label','Right axes variables','Callback',{@obj.reorderGUI,'right'});
            fc = uimenu(propertiesMenu,'Label','Fan Chart','tag','enableWhenLine','Callback','');
                uimenu(fc,'Label','Default',    'Callback',{@obj.fanChartGUI,'default'});
                uimenu(fc,'Label','Variables',  'Callback',{@obj.fanChartGUI,'variable'});
                uimenu(fc,'Label','Dataset',    'Callback',{@obj.fanChartGUI,'dataset'});
                uimenu(fc,'Label','Remove',     'Callback',{@obj.fanChartGUI,'remove'});
            uimenu(propertiesMenu,'Label','Fan Legend','tag','enableWhenLine','Callback',@obj.fanLegendGUI);
            uimenu(propertiesMenu,'Label','Patch','tag','removedWhenDatesVsDates','Callback',@obj.patchGUI);
            uimenu(propertiesMenu,'Label','Legend','Callback',@obj.legendGUI);
            uimenu(propertiesMenu,'Label','Title','tag','title','Callback',@obj.addAxesTextGUI);
            uimenu(propertiesMenu,'Label','X-Axis Label','tag','xlabel','Callback',@obj.addAxesTextGUI);
            yLab = uimenu(propertiesMenu,'Label','Y-Axis Label','Callback','');
                uimenu(yLab,'Label','Left','tag','yLabel','Callback',@obj.addAxesTextGUI);
                uimenu(yLab,'Label','Right','tag','yLabelRight','Callback',@obj.addAxesTextGUI);
            uimenu(propertiesMenu,'Label','Axes','Callback',@obj.axesPropertiesGUI); 
            uimenu(propertiesMenu,'Label','Remove Observations','Callback',@obj.removeObservationsGUI);
            uimenu(propertiesMenu,'Label','Look Up','Callback',@obj.lookUpGUI);  
            uimenu(propertiesMenu,'Label','General','Callback',@obj.generalPropertiesGUI); 
            spec = uimenu(propertiesMenu,'Label','Special'); 
                uimenu(spec,'Label','Dates vs Dates','Callback',@obj.datesToPlotGUI);
            
            uimenu(annotationMenu,'Label','Horizontal Line','tag','removeWhenRadarPie','Callback',{@obj.lineGUI,'horizontal'});
            uimenu(annotationMenu,'Label','Vertical Line','tag','removeWhenRadarPie2','Callback',{@obj.lineGUI,'vertical'});
            uimenu(annotationMenu,'Label','Highlighted Area','tag','removeWhenRadarPie2','Callback',@obj.highlightGUI);
            uimenu(annotationMenu,'Label','Text Box','separator','on','Callback',@obj.addTextBox);
            uimenu(annotationMenu,'Label','Rectangle','Callback',@obj.addDrawPatch);
            uimenu(annotationMenu,'Label','Circle','Callback',@obj.addDrawPatch);
            uimenu(annotationMenu,'Label','Arrow','Callback',@obj.addArrow);
            uimenu(annotationMenu,'Label','Text Arrow','Callback',@obj.addTextArrow);
            uimenu(annotationMenu,'Label','Curly Brace','Callback',@obj.addCurlyBrace);
            uimenu(annotationMenu,'Label','Draw line','Callback',@obj.addDrawLinesAnnotation);
            uimenu(annotationMenu,'Label','Regression line','Callback',@obj.addRegressionLinesAnnotation);
            uimenu(annotationMenu,'Label','Plot Labels','Callback',@obj.addPlotLabelsAnnotation);
            uimenu(annotationMenu,'Label','Color bar','Callback',@obj.addColorBarAnnotation);
            bar = uimenu(annotationMenu,'Label','Bar Annotation','separator','on');
                uimenu(bar,'Label','Add','callback',@obj.addBarAnnotation);
                uimenu(bar,'Label','Edit...','callback',@obj.editBarAnnotation);
                uimenu(bar,'Label','Delete','callback',@obj.deleteBarAnnotation);    
                
        end
        
        %==================================================================
        function [message,retcode,s] = updatePropsWhenReset(obj,newDataSource)
        % Update properties dependent on the data source when the data is
        % reset. Used in the GUI. See also resetDataSource.
        
            retcode = 0;
            s       = struct('properties',struct);
            message = '';
            if ~isa(newDataSource,class(obj.DB))
                
                retcode = 1;
                message = 'Cannot plot the data type of the updated data in a time-series graph. Save it to a new dataset and graph that dataset!';
                return

            else
                
                % Check the date properties
                %---------------------
                if isempty(newDataSource.frequency)
                    freq = 0;
                else
                    freq = newDataSource.frequency;
                end

                if obj.DB.frequency ~= freq || isempty(newDataSource)

                    if isempty(newDataSource)
                        message = 'The changed data is empty. All data dependent settings will be set to default values!';
                    else
                        message = 'The frequency of the data has changed. All the settings that relates to dates will be set to default!';
                    end

                    s.properties.endGraph          = newDataSource.endDate;
                    s.properties.startGraph        = newDataSource.startDate;
                    s.properties.barShadingDate    = nb_date;
                    s.properties.defaultFans       = nb_date;
                    s.properties.datesToPlot       = {};
                    s.properties.highlight         = {};
                    s.properties.highlightColor    = {};
                    s.properties.nanAfterDate      = nb_date;
                    s.properties.nanBeforeDate     = nb_date;
                    s.properties.nanVariables      = {};
                    s.properties.scatterDates      = {};
                    s.properties.scatterDatesRight = {};
                    s.properties.stopStrip         = {};
                    s.properties.verticalLine      = {};
                    s.properties.verticalLineColor = {};
                    s.properties.verticalLineLimit = {};
                    s.properties.verticalLineStyle = {'--'};
                    s.properties.xTickFrequency    = '';
                    s.properties.xTickStart        = nb_date;

                    if strcmpi(obj.missingValues,'both')
                        s.properties.missingValues = 'interpolate';
                    end

                else

                    
                    if ~isempty(obj.datesToPlot)
                    
                        datTP = interpretDatesToPlot(obj,'string');
                        ind   = ismember(datTP,newDataSource.dates);
                        datTP = obj.datesToPlot;
                        s.properties.datesToPlot = datTP(ind);
                        
                        removed = datTP(~ind);
                        if ~isempty(removed)
                            string     = nb_cellstr2String(removed,', ',' and ');
                            newMessage = ['Some of the plotted dates are not in the new data source, so they will not be plotted; ' string];
                            message    = nb_addMessage(message,newMessage);                           
                        end
                        
                        if newDataSource.endDate < obj.endGraph
                            s.properties.endGraph = newDataSource.endDate;
                        elseif obj.endGraph < newDataSource.startDate
                            s.properties.endGraph = newDataSource.endDate;
                        end
                        
                        if newDataSource.endDate < obj.startGraph
                            s.properties.startGraph = newDataSource.startDate;
                        elseif obj.startGraph < newDataSource.startDate
                            s.properties.startGraph = newDataSource.startDate;
                        end
                        
                    else
                        
                        if get(obj,'manuallySetEndGraph')
                            if newDataSource.endDate < obj.endGraph
                                newMessage = ['The graphs end date is after the end date of the dataset (' newDataSource.endDate.toString() '). Reset to ' newDataSource.endDate.toString()];
                                message    = nb_addMessage(message,newMessage);
                                s.properties.endGraph = newDataSource.endDate;
                            elseif obj.endGraph < newDataSource.startDate
                                s.properties.endGraph = newDataSource.endDate;
                                newMessage = ['The end graph date is before the start date of the dataset (' newDataSource.startDate.toString() '). Reset to ' newDataSource.endDate.toString()];
                                message    = nb_addMessage(message,newMessage);
                            end
                        end
                        
                        if get(obj,'manuallySetStartGraph')
                            if newDataSource.endDate < obj.startGraph
                                s.properties.startGraph = newDataSource.startDate;
                                newMessage = ['The start graph date is after the end date of the dataset (' newDataSource.startDate.toString() '). Reset to ' newDataSource.startDate.toString()];
                                message    = nb_addMessage(message,newMessage);
                            elseif obj.startGraph < newDataSource.startDate
                                newMessage = ['The graphs start date is before the start date of the dataset (' newDataSource.startDate.toString() '). Reset to ' newDataSource.startDate.toString()];
                                message    = nb_addMessage(message,newMessage);
                                s.properties.startGraph = newDataSource.startDate;
                            end
                        end
                        
                    end

                    if isa(obj.barShadingDate,'nb_date') || ischar(obj.barShadingDate)
                        [s.properties.barShadingDate,message] = nb_graph_ts.checkDates(obj.barShadingDate,message,1,1,newDataSource,'bar shading date');
                    else
                        [s.properties.barShadingDate,message] = nb_graph_ts.checkDates(obj.barShadingDate,message,2,2,newDataSource,'bar shading date');
                    end
                    [s.properties.dashedLine,message]        = nb_graph_ts.checkDates(obj.dashedLine,message,1,1,newDataSource,'dashed line start date');
                    [s.properties.defaultFans,message]       = nb_graph_ts.checkDates(obj.defaultFans,message,1,1,newDataSource,'default fans start date');
                    [s.properties.highlight,message]         = nb_graph_ts.checkDates(obj.highlight,message,1,1,newDataSource,'dates of the highlight areas');
                    [s.properties.nanAfterDate,message]      = nb_graph_ts.checkDates(obj.nanAfterDate,message,1,1,newDataSource,'nan after date');
                    [s.properties.nanBeforeDate,message]     = nb_graph_ts.checkDates(obj.nanBeforeDate,message,1,1,newDataSource,'nan before date');
                    [s.properties.scatterDates,message]      = nb_graph_ts.checkDates(obj.scatterDates,message,2,2,newDataSource,'dates of the scatter groups');
                    [s.properties.scatterDatesRight,message] = nb_graph_ts.checkDates(obj.scatterDatesRight,message,2,2,newDataSource,'dates of the scatter groups (right)');
                    [s.properties.stopStrip,message]         = nb_graph_ts.checkDates(obj.stopStrip,message,1,1,newDataSource,'stop stripping date');
                    [s.properties.verticalLine,message]      = nb_graph_ts.checkDates(obj.verticalLine,message,1,1,newDataSource,'dates of the vertical lines');
                    [s.properties.xTickStart,message]        = nb_graph_ts.checkDates(obj.xTickStart,message,1,1,newDataSource,'X-axis tick mark start date',obj.xTickFrequency);
                        
                end

                % Check the variables properties
                %-------------------------------
                vars = newDataSource.variables;
                if ~isempty(obj.fanVariable)
                
                    if ~any(strcmp(obj.fanVariable,vars))
                        s.properties.fanVariable = '';
                        
                        newMessage = 'The given fan variable will be removed by your changes to the data. Default will be used.';
                        message    = nb_addMessage(message,newMessage);
                    end
                    
                end
                
                if ~isempty(obj.fanVariables)
                    
                    ind = ismember(obj.fanVariables,vars);
                    s.properties.fanVariables = obj.fanVariables(ind);
                    if not(all(ind))
                        newMessage = ['The given fan layer variables will be removed by your changes to the data; ' ...
                            nb_cellstr2String(obj.fanVariables(~ind),', ',' and ') '. Default will be used.'];
                        message    = nb_addMessage(message,newMessage);
                    end
                     
                end
                
                if ~isempty(obj.scatterVariables)
                    % If not both scattervariables are found we must remove
                    % the scatter options
                    updateScatterVariables(obj,'left');
                    s.properties.scatterVariables = obj.scatterVariables;
                    for ii = 1:length(obj.scatterVariables)
                        [s,message] = checkOneScatterGroup(obj,s,vars,ii,'scatterVariables','scatterDates',message);
                    end
                end
                
                if ~isempty(obj.scatterVariablesRight)
                    % If not both scattervariables are found we must remove
                    % the scatter options
                    updateScatterVariables(obj,'right');
                    s.properties.scatterVariablesRight = obj.scatterVariables;
                    for ii = 1:length(obj.scatterVariablesRight)
                        [s,message] = checkOneScatterGroup(obj,s,vars,ii,'scatterVariablesRight','scatterDatesRight',message);
                    end
                end
                
                if ~isempty(obj.candleVariables)
                    
                    candleVars = obj.candleVariables;
                    ind        = ismember(candleVars(2:2:end),vars);
                    if all(~ind)
                        
                        s.properties.candleVariables = {};
                        if strcmpi(obj.plotType,'candle')
                            cvars      = candleVars(2:2:end);
                            newMessage = ['All the given candle variables will be removed by your changes to the data; ' ...
                                nb_cellstr2String(cvars(~ind),', ',' and ') '. Nothing to plot!'];
                            message    = nb_addMessage(message,newMessage);
                        end
                        
                    elseif ~all(ind)
                        
                        indProp = repmat(ind,2,1);
                        indProp = indProp(:)';
                        s.properties.candleVariables = obj.candleVariables(indProp); 
                        
                        if strcmpi(obj.plotType,'candle')
                            cvars      = candleVars(2:2:end);
                            newMessage = ['Some of the given candle variables will be removed by your changes to the data; ' ...
                                nb_cellstr2String(cvars(~ind),', ',' and ') '.'];
                            message    = nb_addMessage(message,newMessage);
                        end
                        
                    end
                    
                end
                
                if ~isempty(obj.variablesToPlot)
                
                    varsTP   = obj.variablesToPlot;
                    ind      = ismember(varsTP,vars);
                    varsTR   = varsTP(~ind);
                    if ~isempty(varsTR)
                       
                        if ~(strcmpi(obj.plotType,'scatter') || strcmpi(obj.plotType,'candle'))
                            newMessage = ['Some of the given variables to plot will be removed by your changes to the data; ' ...
                                    nb_cellstr2String(varsTR,', ',' and ') '.'];
                            message    = nb_addMessage(message,newMessage);
                        end
                        s.properties.variablesToPlot = varsTP(ind);
                        
                    end
                    
                end
                
                if ~isempty(obj.variablesToPlotRight)
                
                    varsTP   = obj.variablesToPlotRight;
                    ind      = ismember(varsTP,vars);
                    varsTR   = varsTP(~ind);
                    
                    if ~isempty(varsTR)
                        
                        s.properties.variablesToPlotRight = varsTP(ind);
                        if ~(strcmpi(obj.plotType,'scatter') || strcmpi(obj.plotType,'candle'))
                            newMessage = ['Some of the given variables to plot will be removed by your changes to the data; ' ...
                                    nb_cellstr2String(varsTR,', ',' and ') '.'];
                            message    = nb_addMessage(message,newMessage);
                        end
                        
                    end
                    
                end
                
            end
            
        end
        
        %==================================================================
        function [s,message] = checkOneScatterGroup(obj,s,vars,ind,prop,propDates,message)
           
            test = ismember(obj.(prop){ind},vars);
            if ~all(test)
                s.properties.(prop)      = [s.properties.(prop)(1:ind-1),s.properties.(prop)(ind+1:end)];
                s.properties.(propDates) = [s.properties.(propDates)(1:ind*2-2),s.properties.(propDates)(ind*2+1:end)];
                if strcmpi(obj.plotType,'scatter')
                    newMessage = ['The given scatter variables will be removed by your changes to the data; ' ...
                        nb_cellstr2String(obj.(prop){ind},', ',' and ') '. Nothing to plot!'];
                    message    = nb_addMessage(message,newMessage);
                end
            end
            
        end
        
        %==================================================================
        function out = interpretDatesToPlot(obj,type)
            
            switch lower(type)
                
                case 'string'
            
                    out = obj.datesToPlot;
                    if isstruct(obj.localVariables)

                        for ii = 1:size(out,2)

                            try

                                date = out{ii};
                                if ischar(date)
                                    ind  = strfind(date,'%#');
                                    if ~isempty(ind)

                                        date = nb_localVariables(obj.localVariables,date);
                                        try
                                            nb_date.toDate(date,obj.DB.frequency);
                                        catch
                                            error('nb_graph:LocalVariableError',[mfilename ':: Unsupported date %' date ' for frequency ' nb_date.getFrequencyAsString(obj.DB.frequency) ...
                                                             ' given to the property verticalLine with local variable notation.'])
                                        end
                                        out{ii} = date;
                                    end
                                end

                            catch ME

                                if strcmpi(ME.identifier,'nb_graph:LocalVariableError')
                                    rethrow(ME);
                                else
                                    error([mfilename ':: Wrong input given to the datesToPlot property. Must be a cell array of strings; {''1994Q1'',''1994Q4''}']);
                                end

                            end

                        end

                    end
                    
                case 'object'
                    
                    chck = isstruct(obj.localVariables);
                    out  = obj.datesToPlot;
                    for ii = 1:size(out,2)

                        try

                            date = out{ii};
                            if ischar(date)
                                ind  = strfind(date,'%#');
                                if ~isempty(ind) && chck
                                    date = nb_localVariables(obj.localVariables,date);
                                end

                                try
                                    date = nb_date.toDate(date,obj.DB.frequency);
                                catch
                                    error('nb_graph:LocalVariableError',[mfilename ':: Unsupported date %' date ' for frequency ' nb_date.getFrequencyAsString(obj.DB.frequency) ...
                                                     ' given to the property verticalLine with local variable notation.'])
                                end
                                out{ii} = date;

                            end

                        catch ME

                            if strcmpi(ME.identifier,'nb_graph:LocalVariableError')
                                rethrow(ME);
                            else
                                error([mfilename ':: Wrong input given to the datesToPlot property. Must be a cell array of strings; {''1994Q1'',''1994Q4''}']);
                            end

                        end

                    end
                    
            end
            
        end
        
        function [lVarsXNew,lVarsYNew] = getLabelVariablesScatter(obj,type)
        % Get labels of scatter plot
        %
        % - type : > 1         : For nb_displayValue
        %          > otherwise : For nb_plotLabels
        
            lVarsXNew = {};
            lVarsYNew = {};
            if ~isempty(obj.scatterDates)
                
                scDates = obj.interpretScatterDates;
                for ii = 2:2:size(scDates,2)
                    startTemp = nb_date.toDate(scDates{ii}{1},obj.DB.frequency);
                    endTemp   = nb_date.toDate(scDates{ii}{2},obj.DB.frequency);
                    lVarsXNew = [lVarsXNew, {startTemp:endTemp}]; %#ok<AGROW>
                end
                
                updateScatterVariables(obj,'left');
                lVarsYNew = obj.scatterVariables;
                if type == 1
                    for ii = 1:length(lVarsYNew)
                        lVarsYNew{ii} = {[lVarsYNew{ii}{1} ',' lVarsYNew{ii}{2}]};
                    end
                end
                
            end

            if ~isempty(obj.scatterDatesRight)
                
                scDates = obj.interpretScatterDatesRight;
                for ii = 2:2:size(scDates,2)
                    startTemp = nb_date.toDate(scDates{ii}{1},obj.DB.frequency);
                    endTemp   = nb_date.toDate(scDates{ii}{2},obj.DB.frequency);
                    lVarsXNew = [lVarsXNew, {startTemp:endTemp}]; %#ok<AGROW>
                end
                
                updateScatterVariables(obj,'right');
                lVarsYNewR = obj.scatterVariablesRight;
                if type == 1
                    for ii = 1:length(lVarsYNewR)
                        lVarsYNewR{ii} = {[lVarsYNewR{ii}{1} ',' lVarsYNewR{ii}{2}]};
                    end
                end
                lVarsYNew  = [lVarsYNew,lVarsYNewR];
                
            end
            
        end
             
    end
    
    %{
    =======================================================================
    Protected methods
    =======================================================================
    %}
    methods (Access=protected)
          
        %{
        -------------------------------------------------------------------
        Clears the handles of the object
        -------------------------------------------------------------------
        %}
        function obj = clearHandles(obj)
            
            if obj.manuallySetFigureHandle == 0
                obj.figureHandle = [];
            end
            
        end
          
        %{
        -----------------------------------------------------------
        Get the default colors
        -----------------------------------------------------------
        %}
        function getColors(obj,tempData,tempDataRight)
            
            if ~obj.manuallySetColorOrder
                obj.colorOrder = [];
            end
            
            if ~obj.manuallySetColorOrderRight
                obj.colorOrderRight = [];
            end
            
            if isempty(obj.colors)
            
                if isempty(obj.colorOrder) && isempty(obj.colorOrderRight)

                    left                = size(tempData,2);
                    right               = size(tempDataRight,2);
                    col                 = nb_plotHandle.getDefaultColors(left + right);
                    obj.colorOrder      = col(1:left,:);
                    obj.colorOrderRight = col(left + 1:end,:);

                else

                    if isempty(obj.colorOrder)
                        fail1 = 1;
                    elseif size(obj.colorOrder,1) ~= size(tempData,2)

                        warning('nb_graph_ts:graph:wrongColorOrderInput',[mfilename ':: The property ''colorOrder'' doesn''t '...
                                'match the number of plotted variables. Default colors will be used.'])
                        fail1 = 1;
                    else
                        fail1 = 0;
                    end

                    if isempty(obj.colorOrderRight)
                        fail2 = 1;
                    elseif size(obj.colorOrderRight,1) ~= size(tempDataRight,2)

                        warning('nb_graph_ts:graph:wrongColorOrderRightInput',[mfilename ':: The property ''colorOrderRight'' doesn''t '...
                                'match the number of plotted variables. Default colors will be used.'])
                        fail2 = 1;
                    else
                        fail2 = 0;  
                    end

                    if fail1 && fail2

                        left                = size(tempData,2);
                        right               = size(tempDataRight,2);
                        col                 = nb_plotHandle.getDefaultColors(left + right);
                        obj.colorOrder      = col(1:left,:);
                        obj.colorOrderRight = col(left + 1:end,:);

                    elseif fail1

                        obj.colorOrder = nb_plotHandle.getDefaultColors(size(tempData,2)); 

                    elseif fail2

                        obj.colorOrderRight = nb_plotHandle.getDefaultColors(size(tempDataRight,2));

                    end

                end
                
            else
                
                % Parse the colors property to find the colors
                % of the variables plotted
                if strcmpi(obj.plotType,'scatter') 
                    
                    obj.colorOrder      = interpretColorsProperty(obj,obj.colors,obj.scatterDates(1:2:end));
                    obj.colorOrderRight = interpretColorsProperty(obj,obj.colors,obj.scatterDatesRight(1:2:end));
                    
                elseif strcmpi(obj.plotType,'candle')
                    
                    obj.colorOrder      = interpretColorsProperty(obj,obj.colors,{'candle'});
                    obj.colorOrderRight = interpretColorsProperty(obj,obj.colors,{'candle'});
                    
                else
                    
                    if strcmpi(obj.graphMethod,'graphInfoStruct') || strcmpi(obj.graphMethod,'graphSubPlots')
                        obj.colorOrder      = interpretColorsProperty(obj,obj.colors,obj.DB.dataNames);
                        obj.colorOrderRight = []; 
                    elseif ~isempty(obj.datesToPlot) 
                        obj.colorOrder      = interpretColorsProperty(obj,obj.colors,obj.datesToPlot);
                        obj.colorOrderRight = []; 
                    else
                        obj.colorOrder      = interpretColorsProperty(obj,obj.colors,obj.variablesToPlot(:)');
                        obj.colorOrderRight = interpretColorsProperty(obj,obj.colors,obj.variablesToPlotRight(:)');
                    end
                        
                end
                
            end
              
        end
        
        %{
        -------------------------------------------------------------------
        Parse optional inputs for the graphInfoStruct method
        -------------------------------------------------------------------
        %}
        function parseInputs(obj,graphInfoStructInputs)
            
            % Initialize fields of the 'inputs' property
            %--------------------------------------------------------------
            fields = {  'colorOrder'
                        'horizontalLine'
                        'legends'
                        'legLocation'
                        'legPosition'
                        'lineStyle'
                        'plotType'
                        'title'
                        'xLabel'
                        'yLabel'
                        'yLabelRight'
                        'yLim'
                        'yLimRight'
                        'ySpacing'
                        'ySpacingRight'};
             
            obj.inputs = struct();        
            for ii = 1:size(fields)
                
                obj.inputs.(fields{ii}) = [];
                
            end
            
            % Parse the optional inputs
            %--------------------------------------------------------------
            for jj = 1:2:size(graphInfoStructInputs,2)
                
                propertyName  = graphInfoStructInputs{jj};
                propertyValue = graphInfoStructInputs{jj + 1};
                
                if ischar(propertyName)
                    
                    switch lower(propertyName)
                            
                        case 'colororder'

                            if isnumeric(propertyValue)
                                obj.inputs.colorOrder = propertyValue;
                            elseif iscellstr(propertyValue)
                                obj.inputs.colorOrder = nb_plotHandle.interpretColor(propertyValue);
                            else
                                error([mfilename ':: The input after ''colorOrder'' must be a double matrix or a cellstr array, with the color order '...
                                                 'of the plotted right axes variables. See documentation on use']);
                            end          
                                    
                        case 'fanvariable'

                            if ischar(propertyValue)
                                obj.inputs.fanVariable = propertyValue;
                            else
                                error([mfilename ':: The input after the ''fanVariable'' property must be a string with the variable the fan chart should be centered around.'])
                            end 
                            
                        case 'horizontalline'

                            if isnumeric(propertyValue)
                                obj.inputs.horizontalLine = propertyValue;
                            else
                                error([mfilename ':: The input after the ''horizontalLine'' property must be a double array with the values to place the horizontal lines.'])
                            end    

                        case 'legends'

                            if iscell(propertyValue) || ischar(propertyValue)
                                obj.inputs.legends           = cellstr(propertyValue);
                                obj.inputs.manuallySetLegend = 1;
                            else
                                error([mfilename ':: The input after the ''legends'' property must be a cell or a char (single or array). For more see documentation.'])
                            end
                            
                        case 'leglocation'

                            if ischar(propertyValue)
                                obj.inputs.legLocation = propertyValue;
                            else
                                error([mfilename ':: The input after the ''legLocation'' property must be a string with where to put the legend in the figure. See info in the nb_graph_ts class.'])
                            end   
                            
                        case 'legposition'
                            
                            if isnumeric(propertyValue)
                                obj.inputs.legPosition = propertyValue;
                            else
                                error([mfilename ':: The input after ''legPosition'' must be a number with the position of the legend. [xPosition yPosition]']);  
                            end
                            
                        case 'linestyle'
                            
                            if iscellstr(propertyValue)
                                obj.inputs.lineStyle = propertyValue;
                            else
                                error([mfilename ':: The input after ''lineStyle'' must be a cellstr']);
                            end

                        case 'plottype'

                            if ischar(propertyValue)
                                obj.inputs.plotType = lower(propertyValue);
                            else
                                error([mfilename ':: The input after the ''plotType'' property must be a string with the plot type. See the documentation of class nb_graph_ts for info on plot types.'])
                            end 
                            
                        case {'title','titleofplot'} 

                            if ischar(propertyValue)
                                obj.inputs.title = propertyValue;
                            else
                                error([mfilename ':: The input after the ''title'' property must be a string with the title of the graph.'])
                            end      
                             
                        case 'xlabel'

                            if ischar(propertyValue)
                                obj.inputs.xLabel = propertyValue;
                            else
                                error([mfilename ':: The input after the ''xLabel'' property must be a string with the x-label of the graph.'])
                            end        
                            
                        case 'ylabel'

                             if ischar(propertyValue)
                                obj.inputs.yLabel = propertyValue;
                             else
                                error([mfilename ':: The input after the ''yLabel'' property must be a string with the y-label of the graph.'])
                             end  
                             
                        case 'ylabelright'

                             if ischar(propertyValue)
                                obj.inputs.yLabelRight = propertyValue;
                             else
                                error([mfilename ':: The input after the ''yLabelRight'' property must be a string with the y-label of the graph.'])
                             end      

                        case 'ylim'

                            if isnumeric(propertyValue)
                                if size(propertyValue,2) == 2 || isempty(propertyValue)
                                    obj.inputs.yLim = propertyValue;
                                else
                                    error([mfilename ':: The input after the ''yLim'' property must be a double vector of size 2. E.g. [lowerBound upperBound].'])
                                end
                            else
                                error([mfilename ':: The input after the ''yLim'' property must be a number with the limits on the y-axis.'])
                            end 
                            
                        case 'ylimright'

                            if isnumeric(propertyValue)
                                if size(propertyValue,2) == 2 || isempty(propertyValue)
                                    obj.inputs.yLimRight = propertyValue;
                                else
                                    error([mfilename ':: The input after the ''yLimRight'' property must be a double vector of size 2. E.g. [lowerBound upperBound].'])
                                end
                            else
                                error([mfilename ':: The input after the ''yLimRight'' property must be a number with the limits on the right y-axis when using the method graphYY.'])
                            end    

                        case 'yspacing'

                            if isnumeric(propertyValue)
                                obj.inputs.ySpacing = propertyValue;
                            else
                                error([mfilename ':: The input after the ''ySpacing'' property must be a number. (the spacing between y-ticks.)'])
                            end

                        case 'yspacingright'

                            if isnumeric(propertyValue)
                                obj.inputs.ySpacingRight = propertyValue;
                            else
                                error([mfilename ':: The input after the ''ySpacingRight'' property must be a number. (the spacing between y-ticks of '...
                                                 'the right axes when using the method graphYY.)'])
                            end    
                            
                        otherwise
                            
                            error([mfilename ':: The method graphInfoStruct() has no option ''' graphInfoStructInputs{jj} '''.'])
                    end

                end
                
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Test the 'variableToPlot' property
        -------------------------------------------------------------------
        %}
        function testVariablesToPlot(obj)
        
            if ~iscellstr(obj.variablesToPlot)
                error([mfilename ':: The ''variablesToPlot'' input must be a cellstr.'])
            end
            
            if ~iscellstr(obj.variablesToPlotRight)
                error([mfilename ':: The ''variablesToPlotRight'' input must be a cellstr.'])
            end
            
            variables = [obj.variablesToPlot obj.variablesToPlotRight];
            
            %--------------------------------------------------------------
            % If you want some graph some expressions, we must calculate
            % them and add them as seperate timeseries
            %--------------------------------------------------------------
            notFound = zeros(1,length(variables));
            for ii = 1:length(variables)
                notFound(ii) = isempty(find(strcmp(variables{ii},obj.DB.variables),1));
            end

            addedVars = variables(logical(notFound));
            if ~isempty(addedVars)
                obj.DB = obj.DB.createVariable(addedVars,addedVars);
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        A methods which graphs the simple rules. MPR style. Can also graph
        rules of a second dataset. Set the property
        'simpleRulesSecondData'.
        -------------------------------------------------------------------
        %}
        function graphSimpleRules(obj)
            
            % Remove the unwanted simple rules
            %--------------------------------------------------------------
            simpleRulesVars = {'QUA_TAYLOR','QUA_GROWTHRULE','QUA_FOREIGNRULE','QUA_MODELBASEDRULE'};
            index           = nb_ts.locateVariables(obj.DB.variables,simpleRulesVars,1,true);
            simpleRulesVars = simpleRulesVars(index);
            simpleRulesData = obj.DB.window(obj.startGraph,obj.endGraph,simpleRulesVars);
            
            % Expand data of the second database if it is not empty
            %--------------------------------------------------------------
            anySecondData = ~isempty(obj.simpleRulesSecondData);
            if anySecondData
                obj.simpleRulesSecondData = obj.simpleRulesSecondData.expand(obj.startGraph,obj.endGraph,'nan','off');
            end

            % Get the QUA_RNFOLIO variable
            %--------------------------------------------------------------
            locRNFOLIO = find(strcmp('QUA_RNFOLIO',obj.DB.variables),1);
            if ~isempty(locRNFOLIO)
                
                if isempty(obj.dashedLine)
                    
                    data    = obj.DB.window(obj.startGraph,obj.endGraph);
                    RNFOLIO = data.getVariable('QUA_RNFOLIO');
                    
                else
                
                    data    = obj.DB.window(obj.startGraph,obj.endGraph);
                    RNFOLIO = data.getVariable('QUA_RNFOLIO');
                    date    = nb_date.toDate(obj.dashedLine,obj.DB.frequency);
                    period  = date - obj.startGraph + 1;

                    if 1 < period < obj.endGraph - obj.startGraph + 1

                        [beforeSplit, afterSplit] = nb_graph.splitData(RNFOLIO, period);

                    end

                    RNFOLIO   = [beforeSplit afterSplit];

                end
                
            else
                
                RNFOLIO = [];

            end
            
            % Set the plot settings and initilaize the data
            %--------------------------------------------------------------
            colorsSR     = {'sky blue','orange','green','purple'}; 
            lineStylesSR = {'-','-','-','-'};
            markersSR    = {'d','s','^','o'};
            
            colorsT   = colorsSR(index);
            lineStyle = lineStylesSR(index);
            marker    = markersSR(index);
            
            % Get the data
            %--------------------------------------------------------------
            data = simpleRulesData.data;
            vars = simpleRulesData.variables;
            loc  = nb_ts.locateVariables(vars,simpleRulesVars,0,true);
            
            % Reorder
            %--------------------------------------------------------------
            colorsT   = colorsT(loc);
            lineStyle = lineStyle(loc);
            marker    = marker(loc);
            
            % Data second database
            %--------------------------------------------------------------
            if anySecondData
                
                temp  = obj.simpleRulesSecondData.window(obj.startGraph,obj.endGraph,simpleRulesVars);
                data2 = temp.data;
                
                % Merge the data
                data  = [data, data2];
                
                vars2 = temp.variables;
                loc2  = nb_ts.locateVariables(vars2,simpleRulesVars,0,true);
                
                colorsSR2     = {'sky blue','orange','green','purple'};
                lineStylesSR2 = {'--','--','--','--'};
                markersSR2    = {'d','s','^','o'};
                
                colorsT    = [colorsT    colorsSR2(loc2)];
                lineStyle = [lineStyle lineStylesSR2(loc2)];
                marker    = [marker    markersSR2(loc2)];
                
            end
            
            % Sight deposit rate
            %--------------------------------------------------------------
            if ~isempty(RNFOLIO)
                
                if size(RNFOLIO,2) == 2
                    data      = [RNFOLIO(:,1) data RNFOLIO(:,2)];
                    colorsT    = ['black'  colorsT    'black'];
                    lineStyle = ['-'      lineStyle '---'];
                    marker    = ['none'   marker    'none'];
                else
                    data      = [RNFOLIO(:,1) data];
                    colorsT    = ['black'  colorsT];
                    lineStyle = ['-'      lineStyle];
                    marker    = ['none'   marker];
                end
                
            end
                
            % Do the plotting    
            %--------------------------------------------------------------
            nb_plot(1:size(data,1),data,...
                    'cData',      colorsT,...
                    'lineStyle',  lineStyle,...
                    'lineWidth',  obj.lineWidth,...
                    'markerSize', obj.markerSize,...
                    'marker',     marker,...
                    'parent',     obj.axesHandle);    
               
            % Evaluate legends of plot
            %--------------------------------------------------------------
            if isempty(obj.legends)
                obj.manuallySetLegend = 1;
                obj.legends = ['QUA_RNFOLIO' simpleRulesVars(loc) ''];
            end
          
        end
        
        %{
        -------------------------------------------------------------------
        Create the data for the bands of the fan chart(s)
        -------------------------------------------------------------------
        %}
        function constructBands(obj)
             
            if ~isempty(obj.fanDatasets)

                if iscell(obj.fanDatasets)
                    
                    %------------------------------------------------------
                    % This section can be use if the bands is in a different
                    % dataset. The data must be the fan layers absolute 
                    % value. The data must be loaded from excel or .mat
                    % files
                    %------------------------------------------------------
                    obj.fanData = nb_ts(obj.fanDatasets);
                    
                elseif isa(obj.fanDatasets,'dyn_ts') || isa(obj.fanDatasets,'nb_ts') || isstruct(obj.fanDatasets)

                    %------------------------------------------------------
                    % Get the data which is used to calculate the 
                    % percentiles Here I assume that each page is one 
                    % simulations. 
                    %------------------------------------------------------
                    if isa(obj.fanDatasets,'dyn_ts')
                        obj.fanData = nb_ts(obj.fanDatasets);
                    else
                        obj.fanData = obj.fanDatasets;
                    end

                else

                    error([mfilename ':: The property ''fanDatasets '' must be given as a cell, a dyn_ts object or a nb_ts object. For more see documentation.'])

                end
                if ~isstruct(obj.fanData)
                    obj.fanData = breakLink(obj.fanData);
                end
                
                % Assure that the fanData property has as least the
                % same timespan as the graph
                if isstruct(obj.fanDatasets)
                    fields = fieldnames(obj.fanData);
                    for ii = 1:length(fields)
                        obj.fanData.(fields{ii}) = expand(obj.fanData.(fields{ii}),obj.startGraph,obj.endGraph,'nan','off');
                    end
                else
                    obj.fanData = expand(obj.fanData,obj.startGraph,obj.endGraph,'nan','off');
                end

            elseif ~isempty(obj.defaultFans)

                 % Construct the default fans around the variables 
                 % 'QSA_GAPNB_Y','QSA_GAP_Y','QUA_DPY_PCPIXE',
                 % 'QUA_DPY_PCPIXE_R' and 'QUA_RNFOLIO'.

                 % Create the upper and lower bands for fan charts
                 getDefaultFans(obj);

            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Derive the default fan layers
        -------------------------------------------------------------------
        %}
        function getDefaultFans(obj)
            
            perBefore = (obj.defaultFans - 1) - obj.startGraph;
            perAfter  = obj.endGraph - (obj.defaultFans - 1);
            
            defaultFanVariables = {'QSA_GAPNB_Y','QSA_GAP_Y','QUA_DPY_PCPI','QUA_DPY_PCPIJAE','QUA_DPY_PCPIXE','QUA_DPY_PCPIXE_R','QUA_RNFOLIO','QUA_RNFOLIO_LATESTMPR'};
            
            defaultFanVariablesIndex = zeros(1,size(defaultFanVariables,2));
            for ii = 1:size(defaultFanVariables,2)
                defaultFanVariablesIndex(ii) = sum(strcmp(defaultFanVariables{ii},obj.DB.variables));
            end
            defaultFanVariablesIndex = logical(defaultFanVariablesIndex);
            
            if isempty(defaultFanVariables(defaultFanVariablesIndex))
                error([mfilename ':: Non of the variables ''QSA_GAPNB_Y'',''QSA_GAP_Y'',''QUA_DPY_PCPI'',''QUA_DPY_PCPIJAE'',''QUA_DPY_PCPIXE'',''QUA_DPY_PCPIXE_R'','...
                                 ' ''QUA_RNFOLIO'' or ''QUA_RNFOLIO_LASTMPR'' exist in the dataset given. '...
                                 'Why do you try to add default fans for these variables then? Set the property ''defaultFans'' to ''''.'])
            else
                
                % Get the central data of the variables 'QSA_GAPNB_Y',
                % 'QSA_GAP_Y','QUA_DPY_PCPI','QUA_DPY_PCPIJAE','QUA_DPY_PCPIXE',
                % 'QUA_DPY_PCPIXE_R' and 'QUA_RNFOLIO'. (The ones that is 
                % found)
                central             = obj.DB.window(obj.startGraph,obj.endGraph,defaultFanVariables(defaultFanVariablesIndex),obj.DB.numberOfDatasets);   
                num                 = size(defaultFanVariables(defaultFanVariablesIndex),2);
                defaultLowerFanData = nan(central.numberOfObservations, num, 4);
                defaultUpperFanData = nan(central.numberOfObservations, num, 4); 
                for ii = 1:4
                    symmetricLayer              = nb_getDefaultFanLayer(ii,perBefore,perAfter,obj.fanFile);
                    defaultLowerFanData(:,:,ii) = -symmetricLayer(:,defaultFanVariablesIndex) + central.data;
                    defaultUpperFanData(:,:,ii) =  symmetricLayer(:,defaultFanVariablesIndex) + central.data;
                end
                
                % Adds the fan layers to a nb_ts object, which we use to
                % graph later on
                obj.fanData = nb_ts({defaultLowerFanData, defaultUpperFanData}, '',...
                                    obj.startGraph, defaultFanVariables(defaultFanVariablesIndex));
                                
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Set the properties of the axes
        -------------------------------------------------------------------
        %}
        function setAxes(obj)
            
            if strcmpi(obj.plotType,'scatter')
                setScatterAxes(obj);
                return
            end
            
            switch obj.graphMethod
                
                case 'graphinfostruct'
                    
                    if isempty(obj.inputs.ySpacing)
                        yspacing = [];
                    else
                        yspacing = obj.inputs.ySpacing;
                    end
                    
                    if isempty(obj.inputs.ySpacingRight)
                        yspacingright = [];
                    else
                        yspacingright = obj.inputs.ySpacingRight;
                    end
                    
                    if isempty(obj.inputs.yLim)
                        ylim = [];
                    else
                        ylim = obj.inputs.yLim;
                    end
                    
                    if ~isempty(obj.mYLim)
                        
                       if isempty(ylim)
                           ylim = [nan,nan];
                       end
                        
                       dat = obj.dataToGraph;
                       if strcmpi(obj.plotType,'area') || strcmpi(obj.plotType,'stacked') || strcmpi(obj.plotType,'dec')
                           dat = sum(dat,2);
                       end
                       
                       bot = min(min(dat));
                       if bot < obj.mYLim(1)
                           ylim(1) = obj.mYLim(1);
                       end

                       top = max(max(dat));
                       if top > obj.mYLim(2)
                           ylim(2) = obj.mYLim(2);
                       end 
                       
                    end
                    
                    if isempty(obj.inputs.yLimRight)
                        ylimright = [];
                    else
                        ylimright = obj.inputs.yLimRight;
                    end
                   
                    % If we are plotting many subplots we need to 
                    % increase the default x-axis spacing
                    num = round(size(obj.GraphStruct.(obj.fieldName),1)/obj.subPlotSize(1));
                    if isempty(obj.spacing) && num > 2
                        xT  = obj.xTick(1:2:end);
                        dat = obj.datesOfGraph(1:2:end);
                    else
                        xT  = obj.xTick;
                        dat = obj.datesOfGraph;
                    end
                    
                case 'graphsubplots'
                    
                    ylim          = obj.yLim;
                    ylimright     = obj.yLimRight;
                    yspacing      = obj.ySpacing;
                    yspacingright = obj.ySpacingRight;
                    
                    % If we are plotting many subplots we need to 
                    % increase the default x-axis spacing
                    if isempty(obj.spacing) && obj.subPlotSize(2) > 2
                        xT  = obj.xTick(1:2:end);
                        dat = obj.datesOfGraph(1:2:end);
                    else
                        xT  = obj.xTick;
                        dat = obj.datesOfGraph;
                    end
                    
                otherwise
                    
                    % Here datesOfGraph will be the variableToPlot when
                    % datesToPlot is not empty
                    dat           = obj.datesOfGraph;
                    ylim          = obj.yLim;
                    ylimright     = obj.yLimRight;
                    yspacing      = obj.ySpacing;
                    yspacingright = obj.ySpacingRight;
                    xT            = obj.xTick;
                    
            end
            
            % Find the x-axis limits
            %--------------------------------------------------------------
            if isempty(obj.datesToPlot)
                xlim = [1, size(obj.dates,1)];
            else
                xlim = [1, length(obj.variablesToPlot)];
            end
            
            % Evaluate the 'addSpace' property
            %--------------------------------------------------------------
            if obj.addSpace(1) ~= 0 || obj.addSpace(2) ~= 0
               
                xlim = [xlim(1) - obj.addSpace(1), xlim(2) + obj.addSpace(2)];
                
            else
                
                if strcmpi(obj.plotType,'dec') || strcmpi(obj.plotType,'stacked') || strcmpi(obj.plotType,'grouped') || strcmpi(obj.plotType,'candle')  
                    
                    if strcmpi(obj.xTickLabelAlignment,'middle')
                        xlim = [xlim(1), xlim(2) + 0.5];
                    else
                        xlim = [xlim(1) - 0.5, xlim(2) + 0.5];
                    end
                    
                elseif xlim(1) == xlim(2)
                    
                    xlim = [xlim(1) - 0.5, xlim(2) + 0.5]; 
                    
                elseif ~isempty(obj.plotTypes)
                    
                    ind1 = find(strcmpi('stacked',obj.plotTypes),1);
                    ind2 = find(strcmpi('grouped',obj.plotTypes),1);
                    if ~isempty(ind1) || ~isempty(ind2) 
                        if strcmpi(obj.xTickLabelAlignment,'middle')
                            xlim = [xlim(1), xlim(2) + 0.5];
                        else
                            xlim = [xlim(1) - 0.5, xlim(2) + 0.5];
                        end 
                    end
                    
                end
                
            end
            
            % Evaluate the 'dateInterpreter' property
            if strcmpi(obj.dateInterpreter,'end')
                xT      = xT - 1;
                xlim(1) = xlim(1) - 1;
            elseif strcmpi(obj.dateInterpreter,'middle')
                xT      = xT - 0.5;
                xlim(1) = xlim(1) - 0.5;
            end
            
            if isempty(obj.variablesToPlotRight)
                obj.yDirRight   = obj.yDir;
                obj.yScaleRight = obj.yScale;
            end
            
            % Translate x-tick labels
            if ~isempty(obj.xTickLabels)
                
                try
                    checked = obj.xTickLabels(1:2:end);
                    new     = obj.xTickLabels(2:2:end);
                    datT    = strtrim(dat);
                    for ii = 1:length(checked)
                        ind = find(strcmpi(checked{ii},datT),1,'last');
                        if ~isempty(ind)
                            dat{ind} = new{ii};
                        end
                    end
                catch Err
                    error([mfilename ':: Wrong input given to the xTickLabels property:: ' Err.message])
                end
                
            end
            
            % Translate text if some properties are used
            if ~isempty(obj.xTickLabels) || ~isempty(obj.datesToPlot)
            
                if ~isempty(obj.lookUpMatrix)
                    for ii = 1:length(dat)
                        dat{ii} = nb_graph.findVariableName(obj,dat{ii});
                    end
                end

                if ~isempty(obj.localVariables)
                    for ii = 1:length(dat)
                        dat{ii} = nb_localVariables(obj.localVariables,dat{ii});
                    end
                end
                for ii = 1:length(dat)
                    dat{ii} = nb_localFunction(obj,dat{ii});
                end
            
            end
            
            if obj.axesFast
                if isempty(ylim)
                    ylim = findYLimitsLeft(obj.axesHandle);
                end
            end
            
            % Set the x-axis tick mark labels. Set the direction and limits 
            % of both the x-axis and y-axis. Also set the font and grid 
            % options.  
            %--------------------------------------------------------------
            obj.axesHandle.alignAxes            = obj.alignAxes;
            obj.axesHandle.fontName             = obj.fontName;
            obj.axesHandle.fontSize             = obj.axesFontSize;
            obj.axesHandle.fontSizeX            = obj.axesFontSizeX;
            obj.axesHandle.fontUnits            = obj.fontUnits;
            obj.axesHandle.fontWeight           = obj.axesFontWeight;
            obj.axesHandle.grid                 = obj.grid;
            obj.axesHandle.gridLineStyle        = obj.gridLineStyle;
            obj.axesHandle.language             = obj.language;
            obj.axesHandle.lineWidth            = obj.axesLineWidth;
            obj.axesHandle.normalized           = obj.normalized;
            obj.axesHandle.precision            = obj.axesPrecision;
            obj.axesHandle.shading              = obj.shading;
            obj.axesHandle.UIContextMenu        = obj.UIContextMenu;
            obj.axesHandle.update               = 'on';
            obj.axesHandle.xLim                 = xlim;
            obj.axesHandle.xLimSet              = 1;
            obj.axesHandle.xTick                = xT;
            obj.axesHandle.xTickSet             = 1;
            obj.axesHandle.xTickLabel           = dat;
            obj.axesHandle.xTickLabelSet        = 1;
            obj.axesHandle.xTickLabelLocation   = obj.xTickLabelLocation;         
            obj.axesHandle.xTickLabelAlignment  = obj.xTickLabelAlignment;
            obj.axesHandle.xTickLocation        = obj.xTickLocation; 
            obj.axesHandle.xTickRotation        = obj.xTickRotation;
            obj.axesHandle.yDir                 = obj.yDir;
            obj.axesHandle.yDirRight            = obj.yDirRight;
            obj.axesHandle.yLim                 = ylim;
            obj.axesHandle.yLimRight            = ylimright;
            obj.axesHandle.yOffset              = obj.yOffset;
            obj.axesHandle.yScale               = obj.yScale;
            obj.axesHandle.yScaleRight          = obj.yScaleRight;
            
            if ~isempty(ylim)
                obj.axesHandle.yLimSet = 1;
            end
            if ~isempty(ylimright)
                obj.axesHandle.yLimRightSet = 1;
            end
            
            % Interpret the y-axis spacing option (Both (if nothing is 
            % plotted on the right side axes) or left)
            %--------------------------------------------------------------
            if ~isempty(yspacing)
                
                if isempty(ylim)
                    ylim = findYLimitsLeft(obj.axesHandle);
                else
                    if all(isnan(ylim))
                        ylimTemp = findYLimitsLeft(obj.axesHandle);
                        ylim     = ylimTemp;
                    elseif isnan(ylim(1))
                        ylimTemp = findYLimitsLeft(obj.axesHandle);
                        ylim(1)  = ylimTemp(1);
                    elseif isnan(ylim(2))
                        ylimTemp = findYLimitsLeft(obj.axesHandle);
                        ylim(2)  = ylimTemp(2);
                    end
                end
                
                yTick                   = ylim(1):yspacing:ylim(2);
                obj.axesHandle.yTick    = yTick;
                obj.axesHandle.yTickSet = 1;
                
                if isempty(obj.variablesToPlotRight)
                    yTickRight                   = ylim(1):yspacing:ylim(2);
                    obj.axesHandle.yTickRight    = yTickRight;
                    obj.axesHandle.yTickRightSet = 1;
                end
                
            end
            
            % Interpret the y-axis spacing option (Only right)
            % This option will have nothing to say if no variables are
            % plotted against the right side axes.
            %--------------------------------------------------------------
            if ~isempty(yspacingright)
                
                if isempty(ylimright)
                    ylimright = findYLimitsRight(obj.axesHandle);
                    if isempty(ylimright)
                        ylimright = findYLimitsLeft(obj.axesHandle);
                    end
                else
                    if all(isnan(ylimright))
                        ylimTemp = findYLimitsRight(obj.axesHandle);
                        if isempty(ylimTemp)
                            ylimTemp = findYLimitsLeft(obj.axesHandle);
                        end
                        ylimright  = ylimTemp;
                    elseif isnan(ylimright(1))
                        ylimTemp = findYLimitsRight(obj.axesHandle);
                        if isempty(ylimTemp)
                            ylimTemp = findYLimitsLeft(obj.axesHandle);
                        end
                        ylimright(1)  = ylimTemp(1);
                    elseif isnan(ylimright(2))
                        ylimTemp = findYLimitsRight(obj.axesHandle);
                        if isempty(ylimTemp)
                            ylimTemp = findYLimitsLeft(obj.axesHandle);
                        end
                        ylimright(2)  = ylimTemp(2);
                    end    
                    
                end
                
                yTickRight                   = ylimright(1):yspacingright:ylimright(2);
                obj.axesHandle.yTickRight    = yTickRight;
                obj.axesHandle.yTickRightSet = 1;
                
            end 
            
            applyNotTickOptions(obj);
            
            % Then update and plot the axes
            %--------------------------------------------------------------
            obj.axesHandle.updateAxes();
             
            % Add listener so that values get displayed in window
            try
                dv = obj.displayValue;
            catch
                dv = true;
            end
            if dv
                [labX,labY] = getLabelVariables(obj);
                func        = @(src,event)nb_displayValue(src,event,labY,labX);
                addlistener(obj.axesHandle,'mouseOverObject',func);
            end
            
        end
        
        %{
        -----------------------------------------------------------
        Set the properties of the scatter plot axes
        -----------------------------------------------------------
        %}
        function setScatterAxes(obj)
            
            % Find the y-axis limits
            %------------------------------------------------------
            ylim          = obj.yLim;
            ylimright     = obj.yLimRight;
            yspacing      = obj.ySpacing;
            yspacingright = obj.ySpacingRight;
            
            % Find the x-axis limits
            %------------------------------------------------------
            xlim          = obj.xLim;
            xspacing      = obj.spacing;
            
            % Find some direction properties
            %------------------------------------------------------
            if isempty(obj.scatterVariablesRight)
                obj.yDirRight   = obj.yDir;
                obj.yScaleRight = obj.yScale;
            end
            
            % Set the x-axis tick mark labels. Set the direction  
            % and limits of both the x-axis and y-axis. Also set  
            % the font and grid options.  
            %------------------------------------------------------
            obj.axesHandle.alignAxes            = obj.alignAxes;
            obj.axesHandle.fontName             = obj.fontName;
            obj.axesHandle.fontSize             = obj.axesFontSize;
            obj.axesHandle.fontUnits            = obj.fontUnits;
            obj.axesHandle.fontWeight           = obj.axesFontWeight;
            obj.axesHandle.grid                 = obj.grid;
            obj.axesHandle.gridLineStyle        = obj.gridLineStyle;
            obj.axesHandle.language             = obj.language;
            obj.axesHandle.lineWidth            = obj.axesLineWidth;
            obj.axesHandle.normalized           = obj.normalized;
            obj.axesHandle.precision            = obj.axesPrecision;
            obj.axesHandle.shading              = obj.shading;
            obj.axesHandle.update               = 'on'; 
            obj.axesHandle.xScale               = obj.xScale;
            obj.axesHandle.xTickLabelLocation   = obj.xTickLabelLocation;         
            obj.axesHandle.xTickLabelAlignment  = obj.xTickLabelAlignment;
            obj.axesHandle.xTickLocation        = obj.xTickLocation; 
            obj.axesHandle.xTickRotation        = obj.xTickRotation;
            obj.axesHandle.yDir                 = obj.yDir;
            obj.axesHandle.yDirRight            = obj.yDirRight;
            obj.axesHandle.yOffset              = obj.yOffset;
            obj.axesHandle.yScale               = obj.yScale;
            obj.axesHandle.yScaleRight          = obj.yScaleRight;

            % Set some x-axis properties
            %------------------------------------------------------
            if ~isempty(xlim)
                
                % Evaluate the 'addSpace' property
                %--------------------------------------------------
                if obj.addSpace(1) ~= 0 || obj.addSpace(2) ~= 0
                    xlim = [xlim(1) - obj.addSpace(1), xlim(2) + obj.addSpace(2)];
                end
                
                obj.axesHandle.xLim    = xlim;
                obj.axesHandle.xLimSet = 1;
            end
            
            % Interpret the x-axis spacing option
            if ~isempty(xspacing)

                xtick = xlim(1):xspacing:xlim(2);
                obj.axesHandle.xTick    = xtick;
                obj.axesHandle.xTickSet = 1;

            end
            
            % Set some y-axes properties
            %------------------------------------------------------
            if ~isempty(ylim)
                obj.axesHandle.yLim    = ylim;
                obj.axesHandle.yLimSet = 1;
            end
            
            if ~isempty(ylimright)
                obj.axesHandle.yLimRight    = ylimright;
                obj.axesHandle.yLimRightSet = 1;
            end

            % Interpret the y-axes spacing options (Both (if   
            % nothing is plotted on the right side axes) or left)
            if ~isempty(yspacing)

                yTick = ylim(1):yspacing:ylim(2);
                obj.axesHandle.yTick    = yTick;
                obj.axesHandle.yTickSet = 1;

                if isempty(obj.variablesToPlotRight)

                    yTickRight = ylim(1):yspacing:ylim(2);
                    obj.axesHandle.yTickRight    = yTickRight;
                    obj.axesHandle.yTickRightSet = 1;

                end

            end

            % Interpret the y-axis spacing option (Only right)
            % This option will have nothing to say if no variables are
            % plotted against the right side axes.
            %--------------------------------------------------------------
            if ~isempty(yspacingright)

                yTickRight = ylimright(1):yspacingright:ylimright(2);
                obj.axesHandle.yTickRight    = yTickRight;
                obj.axesHandle.yTickRightSet = 1;

            end 
            
            % Then update and plot the axes
            %--------------------------------------------------------------
            applyNotTickOptions(obj);
            obj.axesHandle.updateAxes();
            
            % Add listener so that values get displayed in window
            try
                dv = obj.displayValue;
            catch
                dv = true;
            end
            if dv
                [labX,labY] = getLabelVariables(obj);
                func        = @(src,event)nb_displayValue(src,event,labY,labX);
                addlistener(obj.axesHandle,'mouseOverObject',func);
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Adds a MPR looking legend, for the fan chart(s).
        -------------------------------------------------------------------
        %}
        function addFanLegend(obj)
            
            if isempty(obj.variablesToPlot)
                return
            end
            
            % Add a MPR styled legend for the fan charts
            if obj.fanLegend && strcmpi(obj.plotType,'line')
                
                if isempty(obj.fanLegendText)
                    
                    % If not given try to use the default text of the 
                    % legend 
                    obj.fanLegendText = {};

                end
                
                if strcmpi(obj.fanLegendLocation,'outside') && strcmpi(obj.fontUnits,'normalized')
                    % Here we change the normalize factor due to 
                    % reason that the fan legend are plotted on a 
                    % bigger axes then normal                    
                    fS = obj.fanLegendFontSize*0.814417635118204; 
                else                   
                    fS = obj.fanLegendFontSize;                   
                end
               
                nb_fanLegend(obj.axesHandle,obj.fanLegendText,...
                             'fontName',    obj.fontName,...
                             'fontSize',    fS,...   
                             'fontUnits',   obj.fontUnits,...
                             'location',    obj.fanLegendLocation);
                
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Evaluate nan and multiplication options + shrink the data to the
        variables wanted
        -------------------------------------------------------------------
        %}
        function evaluateDataTransAndShrinkOptions(obj)
            
            %--------------------------------------------------------------
            % Load the data
            %--------------------------------------------------------------
            evaluatedData = obj.DB.data;
            if obj.startIndex < 1 || obj.endIndex > size(evaluatedData,1)
                if obj.startIndex < 1 && obj.endIndex > size(evaluatedData,1)
                    obj.DB         = obj.DB.expand(obj.startGraph,obj.endGraph,'nan','off');
                    obj.startIndex = 1;
                    obj.endIndex   = size(evaluatedData,1);
                elseif obj.startIndex < 1
                    obj.DB         = obj.DB.expand(obj.startGraph,'','nan','off');
                    obj.startIndex = 1;
                else
                    obj.DB         = obj.DB.expand('',obj.endGraph,'nan','off');
                    obj.endIndex   = size(evaluatedData,1);
                end
            end
            
            %--------------------------------------------------------------
            % Evaluate the nan options
            %
            % nanVariables input supports local variables syntax
            %--------------------------------------------------------------
            evaluatedData = obj.DB.data;
            evaluatedData = removeObservations(obj,evaluatedData);
            
            if ~isempty(obj.nanAfterDate)
                
                eInd = obj.nanAfterDate - obj.DB.startDate + 1;
                if not(eInd < 0 || eInd > obj.DB.numberOfObservations)
                    evaluatedData = [evaluatedData(1:eInd,:,:); nan(obj.DB.numberOfObservations-eInd,obj.DB.numberOfVariables,obj.DB.numberOfDatasets)];
                end
                
            end
            
            if ~isempty(obj.nanBeforeDate)
                
                sInd = obj.nanBeforeDate - obj.DB.startDate + 1;
                if not(sInd < 0 || sInd > obj.DB.numberOfObservations)
                    evaluatedData = [nan(sInd-1,obj.DB.numberOfVariables,obj.DB.numberOfDatasets); evaluatedData(sInd:end,:,:)];
                end
                
            end
            
            %--------------------------------------------------------------
            % Scale data by the number given by factor, default is 1
            %--------------------------------------------------------------
            evaluatedData = evaluatedData*obj.factor;
            
            %--------------------------------------------------------------
            % Make the data to graph properties; 'dataToGraph' and 
            % 'dataToGraphRight'
            %--------------------------------------------------------------
            
            % Left axes variables
            varIndex = nan(1,length(obj.variablesToPlot));
            for ii = 1:length(obj.variablesToPlot)
                try
                    varIndex(ii) = find(strcmp(obj.variablesToPlot{ii},obj.DB.variables));
                catch Err
                    if strcmp(Err.identifier,'MATLAB:badRectangle') || strcmp(Err.identifier,'MATLAB:subsassignnumelmismatch')
                        error([mfilename ':: variable ' obj.variablesToPlot{ii} ' not found in the dataset']) 
                    else
                        rethrow(Err);
                    end
                end
            end
            
            % When we have datesToPlot we get the data differently 
            if ~isempty(obj.datesToPlot)
                
                datToPlot       = interpretDatesToPlot(obj,'string');
                ind             = nb_ts.locateVariables(datToPlot,obj.DB.dates);
                obj.dataToGraph = evaluatedData(ind,varIndex,:)';             
                return
                
            end
            
            obj.dataToGraph = evaluatedData(obj.startIndex:obj.endIndex,varIndex,:);
            
            % Right axes variables
            varIndexRight = nan(1,length(obj.variablesToPlotRight));
            for ii = 1:length(obj.variablesToPlotRight)
                try
                    varIndexRight(ii) = find(strcmp(obj.variablesToPlotRight{ii},obj.DB.variables));
                catch Err
                    if strcmp(Err.identifier,'MATLAB:badRectangle') || strcmp(Err.identifier,'MATLAB:subsassignnumelmismatch')
                        error([mfilename ':: variable ' obj.variablesToPlot{ii} ' not found in the dataset']) 
                    else
                        rethrow(Err);
                    end
                end
            end
            
            obj.dataToGraphRight = evaluatedData(obj.startIndex:obj.endIndex,varIndexRight,:);
            
        end
        
        function evaluatedData = removeObservations(obj,evaluatedData)
            
            nanVars = obj.nanVariables;
            if ~isempty(nanVars)
                
                for ii=1:2:size(nanVars,2)
                    
                    nanIndex = strcmp(nanVars{ii},obj.DB.variables);
                    
                    if sum(nanIndex)==0
                       warning('nb_graph_ts:nanVariableNotFound',[mfilename ':: did not find the variable, ' nanVars{ii} ', in the dataset'])
                       continue
                    end
                    
                    if size(nanVars{ii+1},2) < 2
                        error([mfilename ':: the property ''nanVariables'' is on the wrong format. Type; help nb_graph_ts.nanVariables for more on this property.'])
                    end
                    
                    type = nanVars{ii+1}{1};
                    
                    switch lower(type)
                        
                        case 'ind'
                            
                            if size(nanVars{ii+1},2) ~= 2
                                error([mfilename ':: the property ''nanVariables'' is on the wrong format (for a type ''' type '''). Type; help nb_graph_ts.nanVariables for more on this property.'])
                            end
                            
                            nanDates = nanVars{ii+1}{2};
                            if ~iscell(nanDates)
                                if ischar(nanDates)
                                    nanDates = cellstr(nanDates);
                                else
                                    error([mfilename ':: the property ''nanVariables'' is on the wrong format (for a type ''' type '''). Type; help nb_graph_ts.nanVariables for more on this property.'])
                                end
                            end
                            
                            % Interpret the dates
                            for jj = 1:length(nanDates)
                                nanDates{jj} = checkDate(obj,nanDates{jj});
                                if isa(nanDates{jj},'nb_date')
                                    nanDates{jj} = toString(nanDates{jj});
                                end
                            end
                                
                            dat = obj.DB.startDate:obj.DB.endDate;
                            ind = ismember(dat,nanDates);
                            ind = repmat(ind,[1,1,obj.DB.numberOfDatasets]);
                            
                        case 'before'
                            
                            if size(nanVars{ii+1},2) ~= 2
                                error([mfilename ':: the property ''nanVariables'' is on the wrong format (for a type ''' type '''). Type; help nb_graph_ts.nanVariables for more on this property.'])
                            end
                            
                            nanDate = nanVars{ii+1}{2};
                            if isempty(nanDate)
                                sInd = 1;
                            else
                                nanDate = checkDate(obj,nanDate);
                                date    = nb_date.toDate(nanDate,obj.DB.frequency);
                                sInd    = date - obj.DB.startDate + 1;
                                if sInd < 0
                                    sInd = 1;
                                elseif sInd > obj.DB.numberOfObservations
                                    sInd = obj.DB.numberOfObservations;
                                end
                            end
                            
                            ind = [true(sInd-1,1,obj.DB.numberOfDatasets); false(obj.DB.numberOfObservations - sInd + 1,1,obj.DB.numberOfDatasets)];
                                
                        case 'after'
                            
                            if size(nanVars{ii+1},2) ~= 2
                                error([mfilename ':: the property ''nanVariables'' is on the wrong format (for a type ''' type '''). Type; help nb_graph_ts.nanVariables for more on this property.'])
                            end

                            nanDate = nanVars{ii+1}{2};
                            if isempty(nanDate)
                                eInd = obj.DB.numberOfObservations;
                            else
                                nanDate = checkDate(obj,nanDate);
                                date    = nb_date.toDate(nanDate,obj.DB.frequency);
                                eInd    = date - obj.DB.startDate + 1;
                                if eInd < 0
                                    eInd = 1;
                                elseif eInd > obj.DB.numberOfObservations
                                    eInd = obj.DB.numberOfObservations;
                                end
                            end
                            
                            ind = [false(eInd,1,obj.DB.numberOfDatasets); true(obj.DB.numberOfObservations-eInd,1,obj.DB.numberOfDatasets)];
                            
                        case 'between'
                            
                            if size(nanVars{ii+1},2) ~= 3
                                error([mfilename ':: the property ''nanVariables'' is on the wrong format (for a type ''' type '''). Type; help nb_graph_ts.nanVariables for more on this property.'])
                            end
                            
                            nanDateS = nanVars{ii+1}{2};
                            if isempty(nanDateS)
                                sInd = 1;
                            else
                                nanDateS = checkDate(obj,nanDateS);
                                date     = nb_date.toDate(nanDateS,obj.DB.frequency);
                                sInd     = date - obj.DB.startDate + 1;
                                if sInd < 0
                                    sInd = 1;
                                elseif sInd > obj.DB.numberOfObservations
                                    sInd = obj.DB.numberOfObservations;
                                end
                            end

                            nanDateE = nanVars{ii+1}{3};
                            if isempty(nanDateE)
                                eInd = obj.DB.numberOfObservations;
                            else
                                nanDateE = checkDate(obj,nanDateE);
                                date     = nb_date.toDate(nanDateE,obj.DB.frequency);
                                eInd     = date - obj.DB.startDate + 1;
                                if eInd < 0
                                    eInd = 1;
                                elseif eInd > obj.DB.numberOfObservations
                                    eInd = obj.DB.numberOfObservations;
                                end
                            end
                            
                            ind = [false(sInd,1,obj.DB.numberOfDatasets); true(eInd - sInd - 1,1,obj.DB.numberOfDatasets); false(obj.DB.numberOfObservations-eInd + 1,1,obj.DB.numberOfDatasets)];
                            
                        case 'beforeandafter'
                    
                            if size(nanVars{ii+1},2) ~= 3
                                error([mfilename ':: the property ''nanVariables'' is on the wrong format (for a type ''' type '''). Type; help nb_graph_ts.nanVariables for more on this property.'])
                            end
                            
                            nanDateS = nanVars{ii+1}{2};
                            if isempty(nanDateS)
                                sInd = 1;
                            else
                                nanDateS = checkDate(obj,nanDateS);
                                date     = nb_date.toDate(nanDateS,obj.DB.frequency);
                                sInd     = date - obj.DB.startDate + 1;
                                if sInd < 0
                                    sInd = 1;
                                elseif sInd > obj.DB.numberOfObservations
                                    sInd = obj.DB.numberOfObservations;
                                end
                            end

                            nanDateE = nanVars{ii+1}{3};
                            if isempty(nanDateE)
                                eInd = obj.DB.numberOfObservations;
                            else
                                nanDateE = checkDate(obj,nanDateE);
                                date     = nb_date.toDate(nanDateE,obj.DB.frequency);
                                eInd     = date - obj.DB.startDate + 1;
                                if eInd < 0
                                    eInd = 1;
                                elseif eInd > obj.DB.numberOfObservations
                                    eInd = obj.DB.numberOfObservations;
                                end
                            end

                            ind = [true(sInd-1,1,obj.DB.numberOfDatasets); false(eInd - sInd + 1,1,obj.DB.numberOfDatasets); true(obj.DB.numberOfObservations-eInd,1,obj.DB.numberOfDatasets)];
                            
                    end
                    
                    tempData      = obj.DB.data(:,nanIndex,:);
                    tempData(ind) = nan;
                    evaluatedData = [evaluatedData(:,1:find(nanIndex)-1,:), tempData, evaluatedData(:,find(nanIndex)+1:end,:)];
                    
                end
                
            end
            
            %===============================
            % SUBFUNCTION
            %===============================
            function out = checkDate(obj,in)
                
                if ischar(in)
                    indS  = strfind(in,'%#');
                    if ~isempty(indS)

                        inT = nb_localVariables(obj.localVariables,in);
                        try
                            in = nb_date.toDate(inT,obj.DB.frequency);
                        catch
                            error('nb_graph:LocalVariableError',[mfilename ':: Unsupported date %' in ' for frequency ' nb_date.getFrequencyAsString(obj.DB.frequency) ...
                                             ' given to the property nanVariables with local variable notation.'])
                        end

                    end
                    out = in;
                    
                else
                    out = in;
                end
                
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Add vertical line
        -------------------------------------------------------------------
        %}
        function addVerticalLine(obj)
            
            if ~isempty(obj.verticalLine)

                verLine         = obj.interpretVerticalLine();
                numberOfVerLine = length(verLine);
                numbOfColors    = size(obj.verticalLineColor,2);
                numbOfStyles    = size(obj.verticalLineStyle,2);
                
                % Ensure that the 'verticalLineColor' property has the
                % same number of elements as the 'verticalLine' property
                %----------------------------------------------------------
                if numberOfVerLine > numbOfColors
                    
                    % Set the default color of all the vertical lines
                    % which doesn't have a color
                    diff          = numberOfVerLine - numbOfColors;
                    defaultColors = cell(1,diff);
                    for ii = 1:diff
                        defaultColors{ii} = [1 0.5 0.2];
                    end
                    obj.verticalLineColor = [obj.verticalLineColor, defaultColors];
                    
                end
                
                % Ensure that the 'verticalLineStyle' property has the
                % same number of elements as the 'verticalLine' property
                %----------------------------------------------------------
                if numberOfVerLine > numbOfStyles
                    
                    % Set the default color of all the vertical lines
                    % which doesn't have a color
                    diff          = numberOfVerLine - numbOfStyles;
                    defaultStyles = cell(1,diff);
                    for ii = 1:diff
                        defaultStyles{ii} = '--';
                    end
                    obj.verticalLineStyle = [obj.verticalLineStyle, defaultStyles];
                    
                end
                
                % Plot the vertical lines
                %----------------------------------------------------------
                for ii = 1:numberOfVerLine
                    
                    % Find out where to place the vertical
                    % forecast line
                    if obj.DB.frequency == 365 && (strcmp(obj.missingValues,'strip') || strcmp(obj.missingValues,'both'))
                        
                        if isnumeric(verLine{ii})
                            x0 = verLine{ii};
                        elseif ischar(verLine{ii})  || isa(verLine{ii},'nb_date')
                            date = nb_date.toDate(verLine{ii},obj.DB.frequency);
                            x0   = find(strcmp(date.toString(),obj.dates));
                            if isempty(x0)
                                error([mfilename ':: The date you have given (' date.toString() ') is either outside the limits or it is strip.'])
                            end
                        else
                            if isnumeric(verLine{ii}{1})
                                x1 = verLine{ii}{1};
                            elseif ischar(verLine{ii}{1})  || isa(verLine{ii}{1},'nb_date')
                                date1 = nb_date.toDate(verLine{ii}{1},obj.DB.frequency);
                                x1    = find(strcmp(date1.toString(), obj.dates));
                            end
                            
                            if isnumeric(verLine{ii}{2})
                                x2 = verLine{ii}{2};
                            elseif ischar(verLine{ii}{2})  || isa(verLine{ii}{2},'nb_date')
                                date2 = nb_date.toDate(verLine{ii}{2},obj.DB.frequency);
                                x2    = find(strcmp(date2.toString(), obj.dates));
                            end
                            x0    = x1 + (x2 - x1)/2;
                            if isempty(x0)
                                error([mfilename ':: The dates you have given is either outside the limits or it is strip. (' date1.toString() ',' date2.toString() ')'])
                            end
                        end
                        
                    else
                        
                        if isnumeric(verLine{ii})
                            x0   = verLine{ii};
                        elseif ischar(verLine{ii}) || isa(verLine{ii},'nb_date')
                            date = nb_date.toDate(verLine{ii},obj.DB.frequency);
                            x0   = date - obj.startGraph + 1;
                        else
                            date1 = nb_date.toDate(verLine{ii}{1},obj.DB.frequency);
                            date2 = nb_date.toDate(verLine{ii}{2},obj.DB.frequency);
                            x0    = date1 - obj.startGraph + 1 + (date2 - date1)/2; 
                        end
                        
                    end
                    
                    color = obj.verticalLineColor{ii};
                    style = obj.verticalLineStyle{ii};
                    
                    try
                        limits = obj.verticalLineLimit{ii};
                        if isempty(limits)
                            indicator = 0;
                        else
                            indicator = 1;
                        end
                    catch
                        indicator = 0;
                    end
                    
                    periods = obj.endGraph - obj.startGraph + 1;
                    if (1 < x0) && (x0 < periods)

                        % Plot it
                        if indicator 
                            nb_line([x0,x0],limits,...
                                    'cData',        color,...
                                    'parent',       obj.axesHandle,...
                                    'lineStyle',    style,...
                                    'linewidth',    obj.verticalLineWidth,...
                                    'legendInfo',   'off');
                        else
                            nb_verticalLine(x0,...
                                            'cData',        color,...
                                            'parent',       obj.axesHandle,...
                                            'lineStyle',    style,...
                                            'linewidth',    obj.verticalLineWidth);
                        end
                        
                    else

                        % The vertical line date is outside the graphing range,
                        % and we do notting.
                        warning('nb_graph_ts:addVerticalLine',['The vertical line date given by the property ''verticalLine(' int2str(ii) ')'' is outside the graphing range and is not plotted.'])
                    end
                    
                end

            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Add fan chart
        -------------------------------------------------------------------
        %}
        function addFanChart(obj)
            
            if isempty(obj.variablesToPlot)
                return
            end
            
            if ~strcmp(obj.plotType,'line')
                return
            end
                
            if ~isempty(obj.fanVariables)

                %------------------------------------------------------
                % This section can be used when you have the bands in 
                % some variables in the same dataset. The data of the 
                % fan must be the absolute value of the given 
                % percentile
                %------------------------------------------------------
                side = 'left';

                if ~isempty(obj.fanDatasets)
                    error([mfilename ':: It is not possible to set both the ''fanVariables'' and ''fanDatasets'' properties at the same time. Set on of them as empty!'])  
                end

                sizeData = obj.endIndex - obj.startIndex + 1; 

                % Create the upper and lower bands for fan charts
                data = nan(sizeData,length(obj.fanVariables));
                for ii = 1:length(obj.fanVariables)

                    indBand = strcmp(obj.fanVariables{ii},obj.DB.variables);
                    if sum(indBand) == 0
                        error([mfilename ':: Did not find the fan variable ' obj.fanVariables{ii} ', in any of the datasets.'])
                    end
                    data(:,ii) = obj.DB.data(obj.startIndex:obj.endIndex, indBand,obj.subPlotIndex);

                end

            elseif ~isempty(obj.fanDatasets) || ~isempty(obj.defaultFans)

                if isempty(obj.fanVariable)

                    % Default variable to plot the fan chart of is the
                    % last element of the 'variablesToPlot' property
                    obj.fanVariable = obj.variablesToPlot{1,end};
                    if isempty(obj.fanVariable)
                        return
                    end

                end

                if iscellstr(obj.fanVariable)
                    if numel(obj.fanPercentiles) > 1
                        error([mfilename ':: When the ''fanVariable'' property is set to a cellstr and the graph() method '...
                            'is used the ''fanPercentiles'' property must be set to a 1x1 double.'])
                    end
                    side = 'left';
                else
                    foundLeft  = sum(strcmp(obj.fanVariable, obj.variablesToPlot));
                    foundRight = sum(strcmp(obj.fanVariable, obj.variablesToPlotRight));
                    if foundLeft
                        side      = 'left';
                    elseif foundRight
                        side      = 'right';
                    else
                        error([mfilename ':: Did not find the variable given by the property ''fanVariable'' in the ''variablesToPlot'' '...
                                        'or ''variablesToPlotRight'' properties.'])
                    end
                end

                if isstruct(obj.fanData) && strcmpi(obj.graphMethod,'graphinfostruct')                        
                    ind   = regexp(obj.fieldName,'\d*$');
                    field = obj.fieldName(1:ind-1);
                    fData = obj.fanData.(field); 
                else
                    fData = obj.fanData;
                end

                if iscellstr(obj.fanVariable)
                    data         = fData.window(obj.startGraph,obj.endGraph,obj.fanVariable);
                    flip         = fliplr(obj.fanVariable);
                    [~,loc]      = ismember(flip,obj.fanVariable);
                    data         = data(:,loc,:);
                    data         = permute(data.data,[1,3,2]);
                    [~,loc]      = ismember(1:length(obj.fanVariable),length(obj.fanVariable):-1:1);
                    obj.fanColor = obj.colorOrder(loc,:);
                elseif sum(strcmp(obj.fanVariable,fData.variables))
                    data = fData.window(obj.startGraph,obj.endGraph,obj.fanVariable);
                    data = permute(data.data,[1,3,2]);
                else
                    try
                        data = createVariable(fData,obj.fanVariable,obj.fanVariable);
                        data = data.window(obj.startGraph,obj.endGraph,obj.fanVariable);
                        data = reshape(data.data,data.numberOfObservations,data.numberOfDatasets,1);
                    catch
                        data = [];
                    end
                end

            else                    
                % Then there is nothing more to do here
                return;                    
            end
                
            if ~isempty(data)

                % Evaluate the factor option
                %------------------------------------------------------
                data = data*obj.factor;

                % If we plot on a nb_graphPanel we must make it
                % robust when setting the yLim property
                %----------------------------------------------
                ylim = obj.yLim;
                if ~isempty(ylim)
                    ind       = data < ylim(1);
                    data(ind) = ylim(1);
                    ind       = data > ylim(2);
                    data(ind) = ylim(2);
                end

                % Plot it
                %------------------------------------------------------
                if strcmpi(obj.fanMethod,'graded')
                    f = nb_gradedFanChart(1:size(data,1),data,...
                                    'alpha',        obj.fanAlpha,...
                                    'parent',       obj.axesHandle,...
                                    'side',         side,...
                                    'style',        obj.fanGradedStyle,...
                                    'lineWidth',    obj.fanGradedLineWidth);
                else
                    f = nb_fanChart(1:size(data,1),data,...
                                    'alpha',        obj.fanAlpha,...
                                    'cData',        obj.fanColor,...
                                    'parent',       obj.axesHandle,...
                                    'percentiles',  obj.fanPercentiles,...
                                    'side',         side,...
                                    'method',       obj.fanMethod);
                end
                
                % Remove the central line
                %------------------------------------------------------
                for ii = 1:length(f.central)
                    set(f.central(ii),'lineStyle','none','legendInfo','off'); 
                end
                
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Add highlighted areas
        -------------------------------------------------------------------
        %}
        function addHighlightArea(obj)
            
            if ~isempty(obj.highlight)
                
                highlightT = interpretHighlight(obj);
                if iscell(highlightT{1})
                    
                    if isempty(obj.highlightColor)
                        
                        numberOfPatches = length(highlightT);
                        obj.highlightColor = cell(1,numberOfPatches);
                        for ii = 1:numberOfPatches
                            obj.highlightColor{ii} = 'light blue';
                        end
                        
                    end
                    
                    if length(obj.highlightColor) ~= length(highlightT)
                    
                        error([mfilename ':: You have provided too few or too many highlight colors with the property ''highlightColor''. '...
                                         'You should have given (' int2str(length(obj.highlight)) ') but have given (' int2str(length(obj.highlightColor)) ')'])
                    end
                    
                    % Plot each patch
                    %------------------------------------------------------
                    for ii = 1:length(highlightT)
                        
                        tempHighlight = highlightT{ii};
                        
                        if isnumeric(tempHighlight{1})
                            startPeriod = tempHighlight{1};
                        else
                            startD      = nb_date.toDate(tempHighlight{1},obj.DB.frequency);
                            startPeriod = startD - obj.startGraph + 1;
                        end
                        
                        if isnumeric(tempHighlight{2})
                            endPeriod = tempHighlight{2};
                        else
                            endD        = nb_date.toDate(tempHighlight{2},obj.DB.frequency);
                            endPeriod   = endD - obj.startGraph + 1;
                        end

                        % Plot the patch
                        %------------------------------------------------------
                        x = [startPeriod, endPeriod];
                        nb_highlight(x,...
                                     'cData',       obj.highlightColor{ii},...
                                     'legendInfo',  'off',...
                                     'parent',      obj.axesHandle);
                             
                    end
                    
                else
                    
                    if isempty(obj.highlightColor)
                        obj.highlightColor = 'light blue';
                    end
                    
                    if size(obj.highlightColor,1) ~= 1
                    
                        error([mfilename ':: You have provided too few or too many highlight colors with the property ''highlightColor''. '...
                                         'You should have given (1) but have given (' int2str(size(obj.highlightColor,1)) ')'])
                    end
                    
                    if isnumeric(highlightT{1})
                        startPeriod = highlightT{1};
                    else
                        startD      = nb_date.toDate(highlightT{1},obj.DB.frequency);
                        startPeriod = startD - obj.startGraph + 1;
                    end

                    if isnumeric(highlightT{2})
                        endPeriod = highlightT{2};
                    else
                        endD        = nb_date.toDate(highlightT{2},obj.DB.frequency);
                        endPeriod   = endD - obj.startGraph + 1;
                    end

                    % Plot the patch
                    %------------------------------------------------------
                    x = [startPeriod, endPeriod];
                    nb_highlight(x,... 
                                 'cData',       obj.highlightColor{1},...
                                 'legendInfo',  'off',...
                                 'parent',      obj.axesHandle);
                
                end
            
            end
             
        end
        
        %{
        -------------------------------------------------------------------
        Plot lines
        -------------------------------------------------------------------
        %}
        function plotLines(obj,side)
            
            if nargin == 1
                side = 'left';
            end
            
            % Load the data to plot
            list = obj.dates;
            if strcmpi(side,'left')

                varOtherSide = obj.variablesToPlotRight;
                type         = 'variablesToPlot';
                if strcmpi(obj.graphMethod,'graphinfostruct') || strcmpi(obj.graphMethod,'graphsubplots')
                    
                    variables = obj.DB.dataNames;
                    if strcmpi(obj.graphMethod,'graphinfostruct')
                        if length(variables)== 1
                            variables = obj.DB.variables;
                        end
                    end
                    
                    for ii = 1:size(variables,2)
                        ind = strfind(variables{ii},'\');
                        if ~isempty(ind)
                            variables{ii} = variables{ii}(ind(end)+1:end);
                        end
                    end
                    
                elseif ~isempty(obj.datesToPlot)
                    varOtherSide = {};
                    variables    = obj.datesToPlot; 
                    type         = 'datesToPlot';
                    list         = obj.variablesToPlot;
                else 
                    variables = obj.variablesToPlot; 
                end
                
                data = obj.dataToGraph;
                col  = obj.colorOrder;
                
            else
                
                varOtherSide = obj.variablesToPlot;
                type         = 'variablesToPlotRight';
                data         = obj.dataToGraphRight;
                variables    = obj.variablesToPlotRight;
                col          = obj.colorOrderRight;
                
            end
            
            
            if isempty(data)
                return
            end
            
            sData = size(data,2);
            
            % Set default options
            %--------------------------------------------------------------
            if isempty(obj.dashedLine)
                defaultLineStyle = {'-'};
            else
                defaultLineStyle = {{'-',obj.dashedLine,'--'}};
            end
            
            lineColor = nan(sData,3);
            lineStyle = repmat(defaultLineStyle,[1,sData]);
            lineW     = ones(1,sData)*obj.lineWidth;
            marker    = repmat({'none'},[1,sData]);
            
            for ii = 1:sData
                lineColor(ii,:) = col(ii,:);
            end
            
            % Interpreter the inputs
            %--------------------------------------------------------------
            lineS  = interpretLineStyles(obj);
            for kk = 1:2:size(lineS,2)
                var    = lineS{kk};
                locVar = find(strcmp(var,variables),1);
                try
                    lineStyle{locVar} = lineS{kk + 1};
                catch 
                    
                    locVarOtherSide = find(strcmp(var,varOtherSide),1);
                    if isempty(locVarOtherSide)
                        warning('nb_graph_ts:plotLines:DidNotFindVariable',[mfilename ':: Did not find the variable ' var ...
                                ' in the ''' type ''' property, which you have given by the ''lineStyles'' property.'])
                    end
                    
                end    
            end
            
            lineWi = obj.lineWidths;
            for kk = 1:2:size(lineWi,2)
                var    = lineWi{kk};
                locVar = find(strcmp(var,variables),1);
                try
                    lineW(locVar) = lineWi{kk + 1};
                catch
                    
                    locVarOtherSide = find(strcmp(var,varOtherSide),1);
                    if isempty(locVarOtherSide)
                        warning('nb_graph_ts:plotLines:DidNotFindVariable',[mfilename ':: Did not find the variable ' var ...
                                ' in the ''' type ''' property, which you have given by the ''lineWidths'' property.'])
                    end
                    
                end    
            end
            
            mark   = obj.markers;
            for kk = 1:2:size(mark,2)
                var    = mark{kk};
                locVar = find(strcmp(var,variables),1);
                try
                    marker{locVar} = mark{kk + 1};
                catch 
                    
                    locVarOtherSide = find(strcmp(var,varOtherSide),1);
                    if isempty(locVarOtherSide)
                        warning('nb_graph_ts:plotLines:DidNotFindVariable',[mfilename ':: Did not find the variable ' var ...
                                ' in the ''' type ''' property, which you have given by the ''markers'' property.'])
                    end
                    
                end

            end
            
            if strcmpi(obj.graphMethod,'graphInfoStruct')
                
                if ~isempty(obj.inputs.lineStyle)
                    lineStyle = obj.inputs.lineStyle;
                end
                
            end
                
            % Decide if we have some splitted line styles
            %--------------------------------------------------------------
            for ii = 1:size(lineStyle,2)
               
                if iscell(lineStyle{ii})
                    
                    if size(lineStyle{ii},2) == 3
                    
                        % Find the split date and it index value
                        date     = lineStyle{ii}{2};
                        if isa(date,'nb_date')
                            date = date.toString();
                        end
                        
                        splitInd = find(strcmp(date,strtrim(list)));
                        if ~isempty(splitInd)
                        
                            if strcmpi(lineStyle{ii}{3},'none')
                                corr = 1;
                            else
                                corr = 0;
                            end
                            
                            % Split the data
                            [beforeSplit,afterSplit] = nb_graph.splitData(data(:,ii),splitInd,corr);
                            data(:,ii)               = beforeSplit; 
                            data                     = [data, afterSplit]; %#ok

                            % Assign the line properties for the line with 
                            % the second line style
                            lineColor = [lineColor; lineColor(ii,:)];    %#ok
                            lineStyle = [lineStyle lineStyle{ii}{3}];    %#ok
                            lineW     = [lineW     lineW(ii)];           %#ok
                            
                            % Check if a specific marker has been 
                            % given to the second line style of the
                            % splitted line
                            varLine = variables{ii};
                            indM2   = find(strcmp([varLine,'(2)'],obj.markers));
                            if isempty(indM2)
                                marker = [marker, marker{ii}];          %#ok
                            else
                                marker = [marker, obj.markers{indM2 + 1}];          %#ok
                            end

                            % Assign the properties for the line with the 
                            % first line style
                            lineStyle{ii} = lineStyle{ii}{1};
                            
                        else
                            
                            if ~isempty(obj.datesToPlot)
                                lineStyle{ii} = lineStyle{ii}{1};
                            else
                                per = nb_dateminus(date,obj.dates{1});
                                if per > 0
                                    % Only the first line style is plotted
                                    lineStyle{ii} = lineStyle{ii}{1};
                                else
                                    % Only the second line style is plotted
                                    lineStyle{ii} = lineStyle{ii}{3};
                                end
                            end
                               
                        end
                        
                    else
                        error([mfilename ':: If the line style for one line is a cell it must be of size 3. E.g. {''-'',''2011Q1'',''--''}.'])
                    end
                end
                
            end
            
            % Do the plotting
            %--------------------------------------------------------------
            numPer      = size(data,1);
            
            nb_plot(1:numPer,data,...
                    'cData',              lineColor,...
                    'lineStyle',          lineStyle,...
                    'lineWidth',          lineW,...
                    'marker',             marker,...
                    'markerFaceColor',    'auto',...
                    'markerSize',         obj.markerSize,...
                    'parent',             obj.axesHandle,...
                    'side',               side);

        end
        
        %{
        -------------------------------------------------------------------
        Create area plot
        -------------------------------------------------------------------
        %}
        function areaPlot(obj,side)
            
            if nargin == 1
                side = 'left';
            end
            
            % Load the data to plot
            %--------------------------------------------------------------
            if strcmpi(side,'left')
                data   = obj.dataToGraph;
                col    = obj.colorOrder;
            else
                data   = obj.dataToGraphRight;
                col    = obj.colorOrderRight;
            end
            
            if isempty(data)
                return
            end
            
            xData = 1:size(data,1);
            
            if ischar(obj.baseValue)
                error([mfilename ':: The ''baseValue'' property can only be set to a variable when plotType is ''grouped'' or ''stacked''.'])
            end
            
            if obj.areaAlpha < 1
                lineW = obj.lineWidth;
            else
                lineW = 1;
            end
            
            % Do the plotting
            %--------------------------------------------------------------
            a = nb_area(xData,data,...
                        'abrupt',           obj.areaAbrupt,...
                        'accumulate',       obj.areaAccumulate,...
                        'baseValue',        obj.baseValue,...
                        'cData',            col,...
                        'faceAlpha',        obj.areaAlpha,...
                        'lineStyle',        '-',...
                        'lineWidth',        lineW,...
                        'parent',           obj.axesHandle,...
                        'side',             side,...
                        'sumTo',            obj.sumTo);

            % Remove the baseline
            %--------------------------------------------------------------
            set(a.baseline,'lineStyle','none','legendInfo','off');    
            
        end
        
        %{
        -------------------------------------------------------------------
        Create bar plot
        -------------------------------------------------------------------
        %}
        function barPlot(obj,side)
            
            if nargin == 1
                side = 'left';
            end
            
            % Load the data to plot
            %--------------------------------------------------------------
            if strcmpi(side,'left')
                data  = obj.dataToGraph;
                col   = obj.colorOrder;
                ylim  = obj.yLim;
            else
                data   = obj.dataToGraphRight;
                col    = obj.colorOrderRight;
                ylim   = obj.yLimRight;
            end
            
            if isempty(data)
                return
            end
            
            xData = 1:size(data,1);
            
            % Decide the shading
            %--------------------------------------------------------------
            if isempty(obj.barShadingDate) || ~isempty(obj.datesToPlot)
                shadedBars = zeros(size(data,1),1);
            else
                
                if isa(obj.barShadingDate,'nb_date')
                
                    periods = obj.barShadingDate - obj.startGraph;
                    left    = obj.endGraph - obj.barShadingDate + 1;

                    if periods > 0 && periods < obj.endGraph - obj.startGraph + 1
                        shadedBars = [zeros(periods,1); ones(left,1)];
                    elseif periods <= 0
                        shadedBars = ones(size(data,1),1);
                    else
                        shadedBars = zeros(size(data,1),1);
                    end
                
                else % A cell {'Var1',dat1,...}
                    
                    if strcmpi(side,'left')
                        vars = obj.variablesToPlot;
                    else
                        vars = obj.variablesToPlotRight;
                    end
                    
                    shadedBars = zeros(size(data));
                    for ii = 1:2:length(obj.barShadingDate)
                        
                        var = obj.barShadingDate{ii};
                        ind = find(strcmpi(var,vars));
                        if ~isempty(ind)
                            date    = obj.barShadingDate{ii+1};
                            periods = date - obj.startGraph;
                            left    = obj.endGraph - date + 1;
                            
                            if periods > 0 && periods < obj.endGraph - obj.startGraph + 1
                                shadedBars(:,ind) = [zeros(periods,1); ones(left,1)];
                            elseif periods <= 0
                                shadedBars(:,ind) = ones(size(data,1),1);
                            else
                                shadedBars(:,ind) = zeros(size(data,1),1);
                            end
                        end
                        
                    end
                
                end
                    
            end
                
            if any(any(shadedBars))
                lineS = '-';
            else
                lineS = 'none';
            end
            
            % Fit to limits
            %---------------------
            if ~isempty(ylim)
                if strcmpi(obj.plotType,'grouped')
                    if ~isnan(ylim(1))
                        data(data<ylim(1)) = ylim(1);
                    end
                    if ~isnan(ylim(2))
                        data(data>ylim(2)) = ylim(2);
                    end
                end
            end 
            
            if ischar(obj.baseValue)
                baseV = getVariable(obj.DB,obj.baseValue,obj.startGraph,obj.endGraph,obj.page);
            else
                baseV = obj.baseValue;
            end
            
            if isempty(obj.barLineWidth)
                lineW = obj.lineWidth;
            else
                lineW = obj.barLineWidth;
                if lineW == 0
                    lineW = 1;
                    lineS = 'none';
                end
            end
            
            % Do the plotting
            %--------------------------------------------------------------
            b = nb_bar(xData,data,...
                       'alpha1',        obj.barAlpha1,...
                       'alpha2',        obj.barAlpha2,...
                       'barWidth',      obj.barWidth,...
                       'baseValue',     baseV,...
                       'blend',         obj.barBlend,...
                       'cData',         col,...
                       'direction',     obj.barShadingDirection,...
                       'edgeColor',     'same',...
                       'lineStyle',     lineS,...
                       'lineWidth',     lineW,...
                       'parent',        obj.axesHandle,...
                       'side',          side,...
                       'shadeColor',    obj.barShadingColor,...
                       'shaded',        shadedBars,...
                       'style',         obj.plotType,...
                       'sumTo',         obj.sumTo);
             
            % Remove the baseline
            %-------------------------------------------------------------- 
            if ischar(obj.baseValue)
                set(b.baseline,'legendInfo','off',...
                               'cData',      obj.baseLineColor,...
                               'lineStyle',  obj.baseLineStyle,...
                               'lineWidth',  obj.baseLineWidth);
            else
                set(b.baseline,'lineStyle','none','legendInfo','off');   
            end
                          
        end
        
        %{
        -----------------------------------------------------------
        Create candle plot
        -----------------------------------------------------------
        %}
        function candlePlot(obj,side)
            
            if nargin == 1
                side = 'left';
            end
            
            % Load the data to plot
            %------------------------------------------------------
            data    = obj.DB.data;
            varSide = obj.DB.variables;
            if strcmpi(side,'left')
                
                if isempty(obj.colors)
                
                    if isempty(obj.colorOrder)
                        col = 'red';
                    else
                        if iscell(obj.colorOrder)
                            col = obj.colorOrder{1};
                        elseif isnumeric(obj.colorOrder)
                            col = obj.colorOrder(1,:);
                        else
                            col = obj.colorOrder;
                        end
                    end
                    
                else
                    
                    ind = find(strcmpi('candle',obj.colors),1,'last');
                    if isempty(ind)
                        col = 'red';
                    else
                        col = obj.colors{ind + 1};
                    end
                    
                end
                
            else
                
                if isempty(obj.colors)
                
                    if isempty(obj.colorOrderRight)
                        col = 'red';
                    else
                        if iscell(obj.colorOrderRight)
                            col = obj.colorOrderRight{1};
                        elseif isnumeric(obj.colorOrder)
                            col = obj.colorOrderRight(1,:);
                        else
                            col = obj.colorOrderRight;
                        end
                    end
                    
                else
                    
                    ind = find(strcmpi('candle',obj.colors),1,'last');
                    if isempty(ind)
                        col = 'red';
                    else
                        col = obj.colors{ind + 1};
                    end
                    
                end
                
            end
            
            xData = 1:size(data,1);
            
            % Parse the candle option
            %------------------------------------------------------
            candleVars = obj.candleVariables;
            if isempty(candleVars) 
                error([mfilename ':: If you want to create a candle plot you need to set the candleVariables property.'])
            else
                
                high      = [];
                low       = [];
                open      = [];
                close     = [];
                indicator = [];
                kk        = 1;
                for ii = 1:2:size(candleVars,2)
                
                    type = candleVars{ii};
                    try
                        var = candleVars{ii + 1};    
                    catch     
                        error([mfilename ':: The candleVariables property must be a even cell array.'])
                    end
                        
                    switch lower(type)
                        
                        case 'open'
                            
                            ind = strcmp(var,varSide);
                            if ~any(ind)
                                error([mfilename ':: Could not find the variable ' var ', which was given as to ''open'' option of the candleVariables property.'])
                            end
                            open       = data(:,ind,:);
                            kk         = kk + 1;
                            
                        case 'close'
                            
                            ind = strcmp(var,varSide);
                            if ~any(ind)
                                error([mfilename ':: Could not find the variable ' var ', which was given as to ''close'' option of the candleVariables property.'])
                            end
                            close      = data(:,ind,:);
                            kk         = kk + 1;
                            
                        case 'high'
                            
                            ind = strcmp(var,varSide);
                            if ~any(ind)
                                error([mfilename ':: Could not find the variable ' var ', which was given as to ''high'' option of the candleVariables property.'])
                            end
                            high       = data(:,ind,:);
                            kk         = kk + 1;
                            
                        case 'low'
                            
                            ind = strcmp(var,varSide);
                            if ~any(ind)
                                error([mfilename ':: Could not find the variable ' var ', which was given as to ''low'' option of the candleVariables property.'])
                            end
                            low        = data(:,ind,:);
                            kk         = kk + 1;
                            
                        case 'indicator'
                            
                            ind = strcmp(var,varSide);
                            if ~any(ind)
                                error([mfilename ':: Could not find the variable ' var ', which was given as to ''indicator'' option of the candleVariables property.'])
                            end
                            indicator  = data(:,ind,:);
                            kk         = kk + 1;
                            
                        otherwise
                            
                            error([mfilename ':: The input ''' type ''' is not supported by the candle plot. Must be ''open'',''close'',''high'',''low'' or ''indicator''.'])
                            
                    end
                    
                end
                        
            end
            
            indicatorWidth = obj.candleWidth + obj.candleWidth/10; 
            
            % Do the plotting
            %------------------------------------------------------
            nb_candle(xData,high,low,open,close,...
                      'candleWidth',        obj.candleWidth,...
                      'cData',              col,...
                      'edgeColor',          'same',...
                      'hlLineWidth',        2.5,...
                      'indicator',          indicator,...
                      'indicatorColor',     obj.candleIndicatorColor,...
                      'indicatorLineStyle', obj.candleIndicatorLineStyle,...
                      'indicatorLineWidth', 4,...
                      'indicatorWidth',     indicatorWidth,...
                      'lineStyle',          '-',...
                      'lineWidth',          1,...
                      'marker',             obj.candleMarker,...
                      'parent',             obj.axesHandle,...
                      'side',               side);
                  
                  
        end
        
        %{
        -------------------------------------------------------------------
        Create scatter plot
        -------------------------------------------------------------------
        %}
        function scatterPlot(obj,side)
            
            if nargin == 1
                side = 'left';
            end
            
            updateScatterVariables(obj,side);
            if strcmpi(side,'left')
                if isempty(obj.scatterDates)
                    return
                end
                scDates = obj.interpretScatterDates;
                scVars  = obj.scatterVariables;
                col     = obj.colorOrder;
            else
                if isempty(obj.scatterDatesRight)
                    return
                end
                scDates = obj.interpretScatterDatesRight;
                scVars  = obj.scatterVariablesRight;
                col     = obj.colorOrderRight;
            end
            
            % Load the data to plot
            %------------------------------------------------------
            data   = obj.DB.double;
            vars   = obj.DB.variables;
            start  = obj.DB.startDate;
            finish = obj.DB.endDate;
            
            % Find the dates to be plotted for each scatter group
            %------------------------------------------------------
            indDates = cell(1,size(scDates,2)/2);
            if size(scDates,2) < 2
                error([mfilename ':: The property scatterDates(Right) must be given by a nested cell '...
                                     'array. E.g. {''scatterGroupName'',{''2012Q1'',''2013Q1''},...}'])
            end
            
            kk = 1;
            for ii = 2:2:size(scDates,2)
                
                if iscell(scDates{ii})
                    
                    if size(scDates{ii},2) ~= 2
                        error([mfilename ':: The property scatterDates(Right) must be given by a nested cell '...
                                     'array. E.g. {''scatterGroupName'',{''2012Q1'',''2013Q1''},...}'])
                    end
                    
                    startTemp = nb_date.toDate(scDates{ii}{1},obj.DB.frequency);
                    endTemp   = nb_date.toDate(scDates{ii}{2},obj.DB.frequency); 
                    indStart  = startTemp - start + 1;
                    indEnd    = endTemp - start + 1;
                    
                    if indStart < 1
                        error([mfilename ':: The start date (' startTemp.toString() ') of the scatter group nr. ' int2str(ii) ' must be greater then or '...
                                         'equal to the start date of the data (' start.toString() ').'])
                    end
                    
                    if indEnd > obj.DB.numberOfObservations
                        error([mfilename ':: The end date (' endTemp.toString() ') of the scatter group nr. ' int2str(ii) ' must be less then or '...
                                         'equal to the end date of the data (' finish.toString() ').'])
                    end
                    
                    if indStart > indEnd
                        error([mfilename ':: The start date (' startTemp.toString() ') of the scatter group nr. ' int2str(ii) ' must be less then or '...
                                         'equal to the end date of of the scatter group (' endTemp.toString() ').'])
                    end
                    
                    indDates{kk} = indStart:indEnd;
                    kk = kk + 1;
                    
                else
                    error([mfilename ':: The property scatterDates(Right) must be given by a nested cell '...
                                     'array. E.g. {''scatterGroupName'',{''2012Q1'',''2013Q1''},...}'])
                end
                
            end
            
            % Get the data to plot
            %------------------------------------------------------
            startTot = finish;
            endTot   = start;
            for ii = 1:length(indDates)
                
                % Get marker
                scTemp = scDates{ii*2 - 1};
                ind    = find(strcmpi(scTemp,obj.markers),1);
                if isempty(ind)
                   marker = 'o';  
                else
                   marker = obj.markers{ind + 1}; 
                end
                if size(scVars{ii},2) ~= 2
                    error([mfilename ':: Each element of the property scatterVariables(Right) must have size 1x2 (with ',...
                                     'the variables to plot for this scatter group).'])
                end
                indVars      = nb_cs.locateStrings(scVars{ii},vars);
                indDatesTemp = indDates{ii};
                xData        = data(indDatesTemp,indVars(1));
                yData        = data(indDatesTemp,indVars(2));
               
                % Do the plotting
                %--------------------------------------------------
                nb_scatter(xData,yData,...
                           'cData',            col(ii,:),...
                           'marker',           marker,...
                           'lineStyle',        obj.scatterLineStyle,...
                           'lineWidth',        obj.lineWidth,...
                           'markerSize',       obj.markerSize,...
                           'parent',           obj.axesHandle,...
                           'side',             side);
                       
                % Add variables to the allVariables variable
                %--------------------------------------------------
                startTemp = start + indDatesTemp(1) - 1;
                if startTemp < startTot
                    startTot = startTemp;
                end
                
                endTemp = start + indDatesTemp(end) - 1;
                if endTemp > endTot
                    endTot = endTemp;
                end
                
            end
            
            % Set the some properties which is important when 
            % saving the data of the object.
            %------------------------------------------------------
            obj.startGraph = startTot;
            obj.endGraph   = endTot;
            
        end
        
        %==================================================================
        function updateScatterVariables(obj,side)
           
            if strcmpi(side,'left')
                scVars  = obj.scatterVariables;
                scDates = obj.scatterDates;
            else
                scVars  = obj.scatterVariablesRight;
                scDates = obj.scatterDatesRight;
            end
            if isempty(scVars)
                try
                    scVars = obj.DB.variables(1:2);
                catch 
                    error([mfilename ':: The given data must have at least two variables when doing scatter plots.'])
                end
            end
            
            numberOfGroups = size(scDates,2)/2;
            if size(scVars,2) == 2 && iscellstr(scVars)
                scVars = {scVars};
                if numberOfGroups > 1
                    scVars = scVars(1,ones(1,numberOfGroups));
                end
            else
                if length(scVars) < numberOfGroups
                    nAdded = numberOfGroups - length(scVars);
                    if numberOfGroups > 1
                        scVars = [scVars,scVars(1,ones(1,nAdded))];
                    end
                end
            end
            
            if strcmpi(side,'left')
                obj.scatterVariables = scVars;
            else
                obj.scatterVariablesRight = scVars;
            end
            
        end
        
        %{
        -----------------------------------------------------------
        Get the scatter plot sizes (represented as double vectors).
        
        Used to get the color order properties correct
        -----------------------------------------------------------
        %}
        function [tempData,tempDataRight] = getScatterSizes(obj)
            
            if isempty(obj.scatterDates)
                tempData = nan(1,1);
            else
                s        = ceil(size(obj.scatterDates,2)/2);
                tempData = nan(1,s);
            end
            
            if ~isempty(obj.scatterDatesRight)
                s             = ceil(size(obj.scatterDatesRight,2)/2);
                tempDataRight = nan(1,s);
            else
                tempDataRight = [];
            end
            
        end

        %{
        -------------------------------------------------------------------
        Plot variables with different plot types in a given plot.
        -------------------------------------------------------------------
        %}
        function addPlotTypes(obj,side)
            
            if nargin == 1
                side = 'left';
            end
            
            % Load the data to plot
            %--------------------------------------------------------------
            list = obj.dates;
            if strcmpi(side,'left')
                
                varOtherSide = obj.variablesToPlotRight;
                type         = 'variablesToPlot';
                data         = obj.dataToGraph;
                col          = obj.colorOrder;
                if strcmpi(obj.graphMethod,'graphinfostruct') || strcmpi(obj.graphMethod,'graphSubPlots')
                    
                    variables = obj.DB.dataNames;
                    if length(variables)== 1
                        variables = obj.DB.variables;
                    end
                    
                    for ii = 1:size(variables,2)
                        ind = strfind(variables{ii},'\');
                        if ~isempty(ind)
                            variables{ii} = variables{ii}(ind(end)+1:end);
                        end
                    end
                    
                elseif ~isempty(obj.datesToPlot)
                    varOtherSide = {};
                    variables    = obj.datesToPlot;
                    type         = 'datesToPlot';
                    list         = obj.variablesToPlot;
                else
                    variables = obj.variablesToPlot;
                end
            else
                varOtherSide = obj.variablesToPlot;
                type         = 'variablesToPlotRight';
                data         = obj.dataToGraphRight;
                col          = obj.colorOrderRight;
                variables    = obj.variablesToPlotRight;
            end
            
            if isempty(data)
                return
            end
            
            sData = size(data,2);
            xData = 1:size(data,1);
            
            % Get the plot types 
            %--------------------------------------------------------------
            plotT = {obj.plotType};
            plotT = plotT(1,ones(1,sData));

            % Interpreter the inputs
            plotTs  = obj.plotTypes;
            for kk = 1:2:size(plotTs,2)
                var    = plotTs{kk};
                locVar = find(strcmp(var,variables),1);
                try
                    plotT{locVar} = plotTs{kk + 1};
                catch 
                    
                    if strcmpi(obj.graphMethod,'graphinfostruct') || strcmpi(obj.graphMethod,'graphSubPlots')
                    
                        warning('nb_graph_ts:addPlotTypes:DidNotFindVariable',[mfilename ':: Did not find the dataset ' var ...
                                    ' in the DB property, which you have given by the ''ploTypes'' property.'])
                        
                    else
                    
                        locVarOtherSide = find(strcmp(var,varOtherSide),1);
                        if isempty(locVarOtherSide)
                            warning('nb_graph_ts:addPlotTypes:DidNotFindVariable',[mfilename ':: Did not find the variable ' var ...
                                    ' in the ''' type ''' property, which you have given by the ''ploTypes'' property.'])
                        end
                        
                    end
                    
                end
            end
            
            % Set default options for the lines
            %--------------------------------------------------------------
            index    = find(strcmpi(plotT,'line'));
            sLData   = size(find(index),2);
            lineVars = variables(index);
            
            if ~isempty(obj.lineWidths)
                
                warning('nb_graph_ts:addPlotTypes:lineWidthsNotAnOption',[mfilename ':: The property ''lineWidths'' will not be setting '...
                        'the width of the lines when lines are combined with other plotting types. Sorry that is not possible!'])
                    
            end
            
            lineStyle = cell(1,sLData);
            marker    = cell(1,sLData);
            
            if isempty(obj.dashedLine)
                defaultLineStyle = '-';
            else
                defaultLineStyle = {'-',obj.dashedLine,'--'};
            end
            
            for ii = 1:sLData
                lineStyle{ii}   = defaultLineStyle;
                marker{ii}      = 'none';
            end
            
            % Interpreter the inputs
            %--------------------------------------------------------------
            lineS  = interpretLineStyles(obj);
            for kk = 1:2:size(lineS,2)
                var    = lineS{kk};
                locVar = find(strcmp(var,lineVars),1);
                try
                    lineStyle{locVar} = lineS{kk + 1};
                catch
                    
                    if strcmpi(obj.graphMethod,'graphinfostruct') || strcmpi(obj.graphMethod,'graphSubPlots')
                    
                        warning('nb_graph_cs:addPlotTypes:DidNotFindVariable',[mfilename ':: Did not find the dataset ' var ...
                                    ' in the DB property, which you have given by the ''lineStyles'' property.'])
                        
                    else
                    
                        locVarOtherSide = find(strcmp(var,varOtherSide),1);
                        if isempty(locVarOtherSide)
                            warning('nb_graph_ts:addPlotTypes:DidNotFindVariable',[mfilename ':: Did not find the variable ' var ...
                                    ' in the ''' type ''' property, which you have given by the ''lineStyles'' property.'])
                        end
                        
                    end
                    
                end    
            end
            
            lineW  = ones(1,length(lineVars))*obj.lineWidth;
            lineWi = obj.lineWidths;
            for kk = 1:2:size(lineWi,2)
                var    = lineWi{kk};
                locVar = find(strcmp(var,lineVars),1);
                try
                    lineW(locVar) = lineWi{kk + 1};
                catch
                    
                    locVarOtherSide = find(strcmp(var,varOtherSide),1);
                    if isempty(locVarOtherSide)
                        warning('nb_graph_ts:plotLines:DidNotFindVariable',[mfilename ':: Did not find the variable ' var ...
                                ' in the ''' type ''' property, which you have given by the ''lineWidths'' property.'])
                    end
                    
                end    
            end
            
            mark   = obj.markers;
            for kk = 1:2:size(mark,2)
                var    = mark{kk};
                locVar = find(strcmp(var,lineVars),1);
                try
                    marker{locVar} = mark{kk + 1};
                catch 
                    
                    if strcmpi(obj.graphMethod,'graphinfostruct') || strcmpi(obj.graphMethod,'graphSubPlots')
                    
                        warning('nb_graph_cs:addPlotTypes:DidNotFindVariable',[mfilename ':: Did not find the dataset ' var ...
                                    ' in the DB property, which you have given by the ''markers'' property.'])
                        
                    else
                    
                        locVarOtherSide = find(strcmp(var,varOtherSide),1);
                        if isempty(locVarOtherSide)
                            warning('nb_graph_ts:addPlotTypes:DidNotFindVariable',[mfilename ':: Did not find the variable ' var ...
                                    ' in the ''' type ''' property, which you have given by the ''markers'' property.'])
                        end
                        
                    end
                    
                end

            end
            
            % Decide if we have some splitted line styles
            %--------------------------------------------------------------
            for ii = 1:size(lineStyle,2)
               
                if iscell(lineStyle{ii})
                    
                    if size(lineStyle{ii},2) == 3
                    
                        locVar  = find(strcmp(lineVars{ii},variables),1);
                        
                        % Find the split date and it index value
                        date = lineStyle{ii}{2};
                        if isa(date,'nb_date')
                            date = date.toString();
                        end
                        
                        splitInd = find(strcmp(date,strtrim(list)));
                        if ~isempty(splitInd)
                        
                            if strcmpi(lineStyle{ii}{3},'none')
                                corr = 1;
                            else
                                corr = 0;
                            end
                            
                            % Split the data
                            dat                      = data(:,locVar);
                            [beforeSplit,afterSplit] = nb_graph.splitData(dat,splitInd,corr);
                            data(:,locVar)           = beforeSplit; 
                            data                     = [data, afterSplit];  %#ok<AGROW>
                            plotT                    = [plotT {'line'}];    %#ok<AGROW>
                            
                            % Assign the line properties for the line with 
                            % the second line style
                            lineStyle = [lineStyle lineStyle{ii}{3}];    %#ok<AGROW>
                            col       = [col;      col(locVar,:)];    %#ok<AGROW>
                            lineW     = [lineW, lineW(ii)]; %#ok<AGROW>
                            
                            % Check if a specific marker has been 
                            % given to the second line style of the
                            % splitted line
                            indM2   = find(strcmp([lineVars{ii},'(2)'],obj.markers));
                            if isempty(indM2)
                                marker = [marker, marker{ii}];          %#ok<AGROW>
                            else
                                marker = [marker, obj.markers{indM2 + 1}];          %#ok<AGROW>
                            end
                            
                            % Assign the properties for the line with the 
                            % first line style
                            lineStyle{ii} = lineStyle{ii}{1};
                            
                        else
                            
                            if ~isempty(obj.datesToPlot)
                                lineStyle{ii} = lineStyle{ii}{1};
                            else
                                per = nb_dateminus(date,obj.dates{1});
                                if per > 0
                                    % Only the first line style is plotted
                                    lineStyle{ii} = lineStyle{ii}{1};
                                else
                                    % Only the second line style is plotted
                                    lineStyle{ii} = lineStyle{ii}{3};
                                end
                            end
                            
                        end
                        
                    else
                        error([mfilename ':: If the line style for one line is a cell it must be of size 3. E.g. {''-'',''2011Q1'',''--''}.'])
                    end
                end
                
            end
            
            % Decide the shading
            %--------------------------------------------------------------
            bInd = strcmpi(plotT,'grouped') | strcmpi(plotT,'stacked');
            nBar = sum(bInd);
            if isempty(obj.barShadingDate) || ~isempty(obj.datesToPlot)
                shadedBars = zeros(size(data,1),1);
            else
                
                if isa(obj.barShadingDate,'nb_date')
                
                    periods = obj.barShadingDate - obj.startGraph;
                    left    = obj.endGraph - obj.barShadingDate + 1;

                    if periods > 0 && periods < obj.endGraph - obj.startGraph + 1
                        shadedBars = [zeros(periods,1); ones(left,1)];
                    elseif periods <= 0
                        shadedBars = ones(size(data,1),1);
                    else
                        shadedBars = zeros(size(data,1),1);
                    end
                    
                else % A cell {'Var1',dat1,...}
                    
                    barVars    = variables(bInd);
                    shadedBars = zeros(size(data,1),nBar);
                    for ii = 1:2:length(obj.barShadingDate)
                        
                        var = obj.barShadingDate{ii};
                        ind = find(strcmpi(var,barVars));
                        if ~isempty(ind)
                            date    = obj.barShadingDate{ii+1};
                            periods = date - obj.startGraph;
                            left    = size(data,1) - periods;
                            if periods > 0 && periods < obj.endGraph - obj.startGraph + 1
                                shadedBars(:,ind) = [zeros(periods,1); ones(left,1)];
                            elseif periods <= 0
                                shadedBars(:,ind) = ones(size(data,1),1);
                            else
                                shadedBars(:,ind) = zeros(size(data,1),1);
                            end
                        end
                        
                    end
                
                end
                    
            end
            
            % Test some given properties
            %--------------------------------------------------------------
            if ~isempty(obj.sumTo)
                warning('nb_graph_ts:addPlotTypes:sumToNotAnOption',[mfilename 'The ''sumTo'' option is not supported for combination plots.'])
            end
            
            if ischar(obj.baseValue)
                baseV = getVariable(obj.DB,obj.baseValue,obj.startGraph,obj.endGraph,obj.page);
            else
                baseV = obj.baseValue;
            end
            
            if any(shadedBars(:))
                edgeLineS = '-';
            else
                edgeLineS = 'none';
            end
            if isempty(obj.barLineWidth)
                edgeLineWidth = obj.lineWidth;
            else
                edgeLineWidth = obj.barLineWidth;
                if edgeLineWidth == 0
                    edgeLineWidth = 1;
                    edgeLineS     = 'none';
                end
            end
            
            % Do the plotting
            %--------------------------------------------------------------
            p = nb_plotComb(xData,data,...
                        'abrupt',        obj.areaAbrupt,...
                        'alpha1',        obj.barAlpha1,...
                        'alpha2',        obj.barAlpha2,...
                        'barWidth',      obj.barWidth,...
                        'baseValue',     baseV,...
                        'blend',         obj.barBlend,...
                        'cData',         col,...
                        'direction',     obj.barShadingDirection,...
                        'edgeColor',     'same',...
                        'edgeLineStyle', edgeLineS,...
                        'edgeLineWidth', edgeLineWidth,...
                        'lineStyle',     lineStyle,...
                        'lineWidth',     lineW,...
                        'marker',        marker,...
                        'markerSize',    obj.markerSize,...
                        'parent',        obj.axesHandle,...
                        'shadeColor',    obj.barShadingColor,...
                        'shaded',        shadedBars,...
                        'side',          side,...
                        'types',         plotT);
                    
            % Remove the baseline
            %--------------------------------------------------------------
            if ischar(obj.baseValue)
                set(p.baseline,'legendInfo','off',...
                               'cData',      obj.baseLineColor,...
                               'lineStyle',  obj.baseLineStyle,...
                               'lineWidth',  obj.baseLineWidth);
            else
                set(p.baseline,'lineStyle','none','legendInfo','off');   
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Add average lines
        -------------------------------------------------------------------
        %}
        function addAverageLine(obj)
            
            if ~isempty(obj.averageLine)
                
                for ii = 1:2:size(obj.averageLine,2)
                    
                    try
                        % Parse inputs
                        %--------------------------------------------------
                        var          = obj.averageLine{ii};
                        settings     = obj.averageLine{ii + 1};
                        calcEnd      = obj.endGraph;
                        calcStart    = obj.startGraph;
                        color        = [0 0 0]; % Black
                        lineStyle    = '-';
                        lineWidthAVG = 2.5;
                        plotEnd      = obj.endGraph;
                        plotStart    = obj.startGraph;
                        side         = 'left';
                        
                        for jj = 1:2:size(settings,2)
                            
                            inputName  = settings{jj};
                            inputValue = settings{jj + 1};
                            
                            switch lower(inputName)
                                
                                case 'calcend'
                                    
                                    calcEnd = nb_date.toDate(inputValue,obj.DB.frequency);
                                    
                                case 'calcstart'
                                    
                                    calcStart = nb_date.toDate(inputValue,obj.DB.frequency);
                                    
                                case 'color'
                                    
                                    color = inputValue;
                                    
                                case 'linestyle'
                                    
                                    lineStyle = inputValue;
                                    
                                case 'linewidth'
                                    
                                    lineWidthAVG = inputValue;
                                    
                                case 'plotend'
                                    
                                    plotEnd = nb_date.toDate(inputValue,obj.DB.frequency);
                                    
                                case 'plotstart'
                                    
                                    plotStart = nb_date.toDate(inputValue,obj.DB.frequency);
                                    
                                case 'side'
                                    
                                    side = inputValue;
                                    
                                otherwise
                                    
                                    error('nb_graph_ts:myOwnError',[mfilename ':: Bad input name ''' inputName '''.'])
                                    
                            end
                            
                        end
                        
                        % Do the plotting
                        %--------------------------------------------------
                        data     = obj.DB.window(calcStart,calcEnd,var);
                        if isempty(data)
                            error('nb_graph_ts:myOwnError',[mfilename ':: The variable ''' var ''' don''t exist in the given data. '...
                                  '(Variable provided in the averageLine property.)'])
                        end
                        meanData = mean(data);
                        meanData = meanData.window(plotStart,plotEnd);
                        meanData = meanData.data;
                        
                        isNaN           = isnan(meanData);
                        firstNotNaN     = meanData(~isNaN);
                        firstNotNaN     = firstNotNaN(1);
                        meanData(isNaN) = firstNotNaN;
                        
                        periodStart = plotStart - obj.startGraph + 1;
                        periodEnd   = plotEnd - obj.startGraph + 1;
                        
                        if periodStart < 1
                            periodStart = 1;
                        end
                        
                        graphPeriods = obj.endGraph - obj.startGraph + 1;
                        if periodEnd > graphPeriods
                            periodEnd = graphPeriods;
                        end
                        
                        xData = periodStart:periodEnd;
                        
                        nb_line(xData,meanData,...
                                'cData',     color,...
                                'lineStyle', lineStyle,...
                                'lineWidth', lineWidthAVG,...
                                'parent',    obj.axesHandle,...
                                'side',      side);
                        
                    catch Err
                        
                        if strcmpi(Err.identifier,'nb_graph_ts:myOwnError')
                            
                            rethrow(Err);
                            
                        else
                            
                            error([mfilename ':: The property ''averageLine'' is not set correctly. Must be a cell on the form '...
                                             '{''var1'',{''propertyName'',propertyValue,...},...}. See the documentation for more on this.']);
                            
                        end
                        
                    end
                    
                end
                
            end
            
        end

        %{
        -------------------------------------------------------------------
        Create x-ticks of the graphs
        -------------------------------------------------------------------
        %}
        function createxTickOfGraph(obj)
            
            if ~isempty(obj.datesToPlot)
                createxTickOfGraphWhenTransposed(obj);
                return
            end
            
            % Find the start end end dates given the wanted frequency
            freq                       = findXTickFrequency(obj);
            [space,start,freq,periods] = findSpacing(obj,freq);
            switch obj.language
                case {'english','engelsk'}
                    [xTickdates,locations] = obj.startGraph.toDates(0:periods,'NBEnglish',freq);
                case {'norsk','norwegian'}
                    [xTickdates,locations] = obj.startGraph.toDates(0:periods,'NBNorsk',freq);
                otherwise
                    error([mfilename ':: The language ' obj.language ' is not supported by this function.'])
            end

            if ~isempty(obj.xTickStart)
                startX = obj.xTickStart - start + 1;
                if startX < 1
                    startX = 1;
                end   
            else
                startX = 1;
            end
            
            % Find the final x-ticks marks given the spacing and assign 
            % the properties of the object
            obj.xTick        = locations(startX:space:end);
            obj.datesOfGraph = xTickdates(startX:space:end);
            obj.dates        = obj.startGraph:obj.endGraph;
            
        end
        
        function freq = findXTickFrequency(obj)
           
            if ~isempty(obj.xTickFrequency)
                freq = nb_date.getFrequencyAsInteger(obj.xTickFrequency);
            else
                if obj.DB.frequency == 365
                    freq = 1;
                else
                    freq = obj.DB.frequency;
                end
            end
            
        end
        
        function [space,start,freq,periods] = findSpacing(obj,freq)
            
            % Find the start end end dates given the wanted frequency
            if freq == obj.DB.frequency
                start  = obj.startGraph;
                finish = obj.endGraph;
            else
                start  = obj.startGraph.getDate(freq);
                finish = obj.endGraph.getDate(freq);  
            end
            
            % Find the spacing between ticks if not given
            if isempty(obj.spacing)
                space = nb_graph_ts.findXSpacing(start,finish); 
            else
                space = obj.spacing;
            end
            
            % Find the x-tick marks
            periods = obj.endGraph - obj.startGraph;
            if obj.DB.frequency == 365
                if periods < 365 && freq == 1
                    start  = obj.startGraph;
                    finish = obj.endGraph;
                    freq   = obj.DB.frequency;
                    if isempty(obj.spacing)
                        space = nb_graph_ts.findXSpacing(start,finish); 
                    else
                        space = obj.spacing;
                    end
                end
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Create x-ticks of the graphs when different dates are plotted
        against eachother
        -------------------------------------------------------------------
        %}
        function createxTickOfGraphWhenTransposed(obj)
            
            obj.xTick        = 1:length(obj.variablesToPlot);
            obj.datesOfGraph = obj.variablesToPlot;
            obj.dates        = obj.datesToPlot;
                       
        end
        
        %{
        -------------------------------------------------------------------
        Function which interpret the missing observations
        
        Either strip or interpolate the missing observations.
        -------------------------------------------------------------------
        %}
        function [obj,data] = interpretMissingData(obj,data,updateDates)
            
            if nargin < 3
                updateDates = 1;
            end
            
            if ~isempty(obj.datesToPlot) && ~strcmpi(obj.missingValues,'none')
                warning('nb_graph_ts:NotAnOption','Cannot use missingValues in combination with datesToPlot.')
                return
            end
              
            if strcmpi(obj.missingValues,'interpolate')

                % Interpolate the data
                data = nb_interpolate(data,'linear');

            elseif strcmpi(obj.missingValues,'strip')

                % Strip the data
                if isempty(obj.stopStrip)
                    periods = size(data,1);
                else
                    periods = obj.stopStrip - obj.startGraph;
                end

                if updateDates
                    [firstPart, obj.xTick, firstDates] = nb_graph.stripData(data(1:periods,:,:),obj.xTick, obj.dates(1:periods));
                    data                               = [firstPart; data(periods+1:end,:,:)];
                    obj.dates                          = [firstDates; obj.dates(periods+1:end)];
                else
                    firstPart  = nb_graph.stripData(data(1:periods,:,:));
                    data       = [firstPart; data(periods+1:end,:,:)];                       
                end

            elseif strcmpi(obj.missingValues,'both')

                % First strip
                if isempty(obj.stopStrip)
                    periods = size(data,1);
                else
                    periods = obj.stopStrip - obj.startGraph;
                end

                if updateDates
                    [firstPart, obj.xTick, firstDates] = nb_graph.stripData(data(1:periods,:,:),obj.xTick, obj.dates(1:periods));
                    secondData                          = data(periods+1:end,:,:);
                    data                                = [firstPart; data(periods+1:end,:,:)];
                    obj.dates                           = [firstDates; obj.dates(periods+1:end)];
                else
                    firstPart  = nb_graph.stripData(data(1:periods,:,:));
                    secondData = data(periods+1:end,:,:);
                    data       = [firstPart; secondData];
                end

                % Then interpolate
                if isempty(obj.stopStrip)
                    data = nb_interpolate(data,'linear');
                else
                    secondData = nb_interpolate(secondData,'linear');
                    data       = [firstPart; secondData];
                end

            end
            
            % Fix x-tick labels
            if any(strcmpi(obj.missingValues,{'strip','both'}))
                fixXTicksWhenStripped(obj);
            end

                
        end
        
        function fixXTicksWhenStripped(obj)
           
            freq                       = findXTickFrequency(obj);
            [space,start,freq,periods] = findSpacing(obj,freq);
            if freq == 365

                locations  = 1:length(obj.dates);
                xTickdates = obj.dates;
                if ~isempty(obj.xTickStart)
                    startX = obj.xTickStart - nb_date.toDate(obj.dates{1},365) + 1;
                    if startX < 1
                        startX = 1;
                    end   
                else
                    startX = 1;
                end

            else
                
                lowDates  = obj.startGraph.toDates(0:periods,'default',freq);
                locations = nan(1,length(lowDates));
                for ii = 1:length(lowDates)
                    dateT  = nb_date.toDate(lowDates{ii},freq);
                    dateTD = dateT.convert(365,true);
                    ind    = [];
                    tt     = 0;
                    while isempty(ind) && tt < 3
                        ind = find(strcmp(toString(dateTD + tt),obj.dates));
                        tt  = tt + 1;
                    end
                    if isempty(ind)
                        locations(ii) = [];
                        lowDates      = lowDates(1:end-1);
                    else
                        locations(ii) = ind;
                    end
                end
                
                startTick = nb_date.toDate(lowDates{1},freq);
                switch obj.language
                    case {'english','engelsk'}
                        xTickdates = startTick.toDates(0:length(locations)-1,'NBEnglish');
                    case {'norsk','norwegian'}
                        xTickdates = startTick.toDates(0:length(locations)-1,'NBNorsk');
                    otherwise
                        error([mfilename ':: The language ' obj.language ' is not supported by this function.'])
                end

                if ~isempty(obj.xTickStart)
                    startX = obj.xTickStart - startTick + 1;
                    if startX < 1
                        startX = 1;
                    end   
                else
                    startX = 1;
                end

            end
            
            obj.xTick        = locations(startX:space:end);
            obj.datesOfGraph = xTickdates(startX:space:end);
            
        end
        
        function out = interpretScatterDates(obj)
            
            out = obj.scatterDates;
            
            if isstruct(obj.localVariables)
                
                for ii = 1:size(out,2)/2

                    try
                        
                        temp = out{ii*2};
                        
                        date = temp{1};
                        if ischar(date)
                            
                            ind = strfind(date,'%#');
                            if ~isempty(ind)
                                    
                                dateParsed = nb_localVariables(obj.localVariables,date);
                                try
                                    date = nb_date.toDate(dateParsed,obj.DB.frequency);
                                catch
                                    error('nb_graph:LocalVariableError',[mfilename ':: Unsupported date %' date ' for frequency ' nb_date.getFrequencyAsString(obj.DB.frequency) ...
                                                     ' given to the property scatterDates with local variable notation.'])
                                end

                            end
                            temp{1} = date;
                            
                        end
                        
                        date = temp{2};
                        if ischar(date)
                            
                            ind = strfind(date,'%#');
                            if ~isempty(ind)
                                    
                                dateParsed = nb_localVariables(obj.localVariables,date);
                                try
                                    date = nb_date.toDate(date,obj.DB.frequency);
                                catch
                                    error('nb_graph:LocalVariableError',[mfilename ':: Unsupported date %' dateParsed ' for frequency ' nb_date.getFrequencyAsString(obj.DB.frequency) ...
                                                     ' given to the property scatterDates with local variable notation.'])
                                end

                            end
                            temp{2} = date;
                            
                        end
                        
                        out{ii*2} = temp;
                        
                    catch ME
                        
                        if strcmpi(ME.identifier,'nb_graph:LocalVariableError')
                            rethrow(ME)
                        else
                            error([mfilename ':: Wrong input given to the scatterDates property. Must be a cell array on the format '...
                                             '{''scatterGroup1'',{''startDate1'',''endDate1''},''scatterGroup2'',{''startDate2'',''endDate2''},...}']);
                        end
                        
                    end

                end
                
            end
            
        end
        
        function out = interpretScatterDatesRight(obj)
            
            out = obj.scatterDatesRight;
            
            if isstruct(obj.localVariables)
                
                for ii = 1:size(out,2)/2

                    try
                        
                        temp = out{ii*2};
                        
                        date = temp{1};
                        if ischar(date)
                            
                            ind = strfind(date,'%#');
                            if ~isempty(ind)
                                    
                                dateParsed = nb_localVariables(obj.localVariables,date);
                                try
                                    date = nb_date.toDate(date,obj.DB.frequency);
                                catch
                                    error('nb_graph:LocalVariableError',[mfilename ':: Unsupported date %' dateParsed ' for frequency ' nb_date.getFrequencyAsString(obj.DB.frequency) ...
                                                     ' given to the property scatterDatesRight with local variable notation.'])
                                end

                            end
                            temp{1} = date;
                            
                        end
                        
                        date = temp{2};
                        if ischar(date)
                            
                            ind = strfind(date,'%#');
                            if ~isempty(ind)
                                    
                                dateParsed = nb_localVariables(obj.localVariables,date);
                                try
                                    date = nb_date.toDate(dateParsed,obj.DB.frequency);
                                catch
                                    error('nb_graph:LocalVariableError',[mfilename ':: Unsupported date %' date ' for frequency ' nb_date.getFrequencyAsString(obj.DB.frequency) ...
                                                     ' given to the property scatterDatesRight with local variable notation.'])
                                end

                            end
                            temp{2} = date;
                            
                        end
                        
                        out{ii*2} = temp;
                        
                    catch ME
                        
                        if strcmpi(ME.identifier,'nb_graph:LocalVariableError')
                            rethrow(ME)
                        else
                            error([mfilename ':: Wrong input given to the scatterDatesRight property. Must be a cell array on the format '...
                                             '{''scatterGroup1'',{''startDate1'',''endDate1''},''scatterGroup2'',{''startDate2'',''endDate2''},...}']);
                        end
                        
                    end

                end
                
            end
            
        end
        
        function out = interpretVerticalLine(obj)
            
            out = obj.verticalLine;
            
            if isstruct(obj.localVariables)
                
                for ii = 1:size(out,2)

                    try
                        
                        temp = out{ii};
                        if iscell(temp)
                        
                            date = temp{1};
                            if ischar(date)
                                ind = strfind(date,'%#');
                                if ~isempty(ind)
                                    
                                    dateParsed = nb_localVariables(obj.localVariables,date);
                                    try
                                        date = nb_date.toDate(dateParsed,obj.DB.frequency);
                                    catch
                                        error('nb_graph:LocalVariableError',[mfilename ':: Unsupported date %' date ' for frequency ' nb_date.getFrequencyAsString(obj.DB.frequency) ...
                                                         ' given to the property verticalLine with local variable notation.'])
                                    end
                                    
                                end
                                temp{1} = date;
                            end
                            
                            date = temp{2};
                            if ischar(date)
                                ind = strfind(date,'%#');
                                if ~isempty(ind)
                                    
                                    dateParsed = nb_localVariables(obj.localVariables,date);
                                    try
                                        date = nb_date.toDate(date,obj.DB.frequency);
                                    catch
                                        error('nb_graph:LocalVariableError',[mfilename ':: Unsupported date %' dateParsed ' for frequency ' nb_date.getFrequencyAsString(obj.DB.frequency) ...
                                                         ' given to the property verticalLine with local variable notation.'])
                                    end
                                    
                                end
                                temp{2} = date;
                            end
                            
                        else
                            
                            date = temp;
                            if ischar(date)
                                ind  = strfind(date,'%#');
                                if ~isempty(ind)
                                    
                                    dateParsed = nb_localVariables(obj.localVariables,date);
                                    try
                                        date = nb_date.toDate(date,obj.DB.frequency);
                                    catch
                                        error('nb_graph:LocalVariableError',[mfilename ':: Unsupported date %' dateParsed ' for frequency ' nb_date.getFrequencyAsString(obj.DB.frequency) ...
                                                         ' given to the property verticalLine with local variable notation.'])
                                    end
                                    
                                end
                                
                                temp = date;
                            end
                            
                        end
                        out{ii} = temp;
                        
                    catch ME
                        
                        if strcmpi(ME.identifier,'nb_graph:LocalVariableError')
                            rethrow(ME);
                        else
                            error([mfilename ':: Wrong input given to the verticalLine property. Must be a cell array on the format '...
                                             '{''date1'',''date2'',{''dat1'',''data2''},...}']);
                        end
                        
                    end

                end
                
            end
            
        end
        
        function out = interpretHighlight(obj)
            
            out = obj.highlight;
            
            if isstruct(obj.localVariables)
                
                if ~iscell(out{1})
                    out = {out};
                end
                
                try
                
                    for ii = 1:size(out,2)

                        temp = out{ii};
                        date = temp{1};
                        if ischar(date)
                            ind = strfind(date,'%#');
                            if ~isempty(ind)

                                dateParsed = nb_localVariables(obj.localVariables,date);
                                try
                                    date = nb_date.toDate(date,obj.DB.frequency);
                                catch %#ok<*CTCH>
                                    error('nb_graph:LocalVariableError',[mfilename ':: Unsupported date %' dateParsed ' for frequency ' nb_date.getFrequencyAsString(obj.DB.frequency) ...
                                                     ' given to the property verticalLine with local variable notation.'])
                                end

                            end
                            temp{1} = date;
                        end

                        date = temp{2};
                        if ischar(date)
                            ind = strfind(date,'%#');
                            if ~isempty(ind)

                                dateParsed = nb_localVariables(obj.localVariables,date);
                                try
                                    date = nb_date.toDate(dateParsed,obj.DB.frequency);
                                catch
                                    error('nb_graph:LocalVariableError',[mfilename ':: Unsupported date %' dateParsed ' for frequency ' nb_date.getFrequencyAsString(obj.DB.frequency) ...
                                                     ' given to the property verticalLine with local variable notation.'])
                                end

                            end
                            temp{2} = date;
                        end
                        out{ii} = temp;

                    end
                        
                catch ME

                    if strcmpi(ME.identifier,'nb_graph:LocalVariableError')
                        rethrow(ME);
                    else
                        error([mfilename ':: Wrong input given to the verticalLine property. Must be a cell array on the format '...
                                         '{''date1'',''date2'',{''dat1'',''data2''},...}']);
                    end

                end
                
            end
            
        end
       
        function out = interpretLineStyles(obj)
        % Interpret the lineStyles property. I.e. check for use
        % of local variables
            
            out = obj.lineStyles;
            
            if isa(obj,'nb_graph_cs')
                return
            end
            
            if isstruct(obj.localVariables)
                
                for ii = 1:size(out,2)/2

                    if iscell(out{ii*2})

                        temp = out{ii*2};
                        date = temp{2};
                        
                        if ischar(date)
                            
                            ind  = strfind(date,'%#');
                            if ~isempty(ind)

                                dateParsed = nb_localVariables(obj.localVariables,date);
                                try
                                    date = nb_date.toDate(dateParsed,obj.DB.frequency);
                                catch
                                    error('nb_graph:LocalVariableError',[mfilename ':: Unsupported date %' date ' for frequency ' nb_date.getFrequencyAsString(obj.DB.frequency) ...
                                                     ' given to the property lineStyles with local variable notation.'])
                                end

                            end
                            temp{2}   = date;
                            
                        end
                        out{ii*2} = temp;

                    end

                end
                
            end
            
        end
        
        function copyObj = copyElement(obj)
        % Overide the copyElement mehtod of the 
        % matlab.mixin.Copyable class to remove some plotting 
        % handles
        
            % Copy main object
            copyObj = copyElement@matlab.mixin.Copyable(obj);
            
            % Make a deep copy of the plotter object
            copyObj.manuallySetFigureHandle = 0;
            copyObj.figureHandle            = [];
            copyObj.axesHandle              = [];
            copyObj.UIContextMenu           = [];
            copyObj.parent                  = [];
%             if isa(copyObj.localVariables,'nb_struct')
%                 copyObj.localVariables = copy(copyObj.localVariables);
%             end
            
            % Copy all the nb_annotation handles
            if iscell(copyObj.annotation)
            
                for ii = 1:length(copyObj.annotation)
                    copied                 = copyObj.annotation{ii};
                    copyObj.annotation{ii} = copy(copied);
                end
                
            elseif isa(copyObj.annotation,'nb_annotation')
                copyObj.annotation = copy(copyObj.annotation);
            end
            
            % Copy the figure title and footer handles
            if ~isempty(copyObj.figTitleObjectEng)
                copyObj.figTitleObjectEng = copy(copyObj.figTitleObjectEng);
            end
            if ~isempty(copyObj.footerObjectNor)
                copyObj.footerObjectNor = copy(copyObj.footerObjectNor);
            end
            if ~isempty(copyObj.footerObjectEng)
                copyObj.footerObjectEng = copy(copyObj.footerObjectEng);
            end
            if ~isempty(copyObj.footerObjectNor)
                copyObj.footerObjectNor = copy(copyObj.footerObjectNor);
            end
            
        end
        
        
        
    end
    
    %----------------------------------------------------------------------
    % Subfunctions
    %----------------------------------------------------------------------
    methods (Static=true,Hidden=true)

        function [cellInput,message] = checkDates(cellInput,message,start,incr,dataSource,propertyName,freq)
            
            if nargin < 7
                freq   = dataSource.frequency;
                startD = dataSource.startDate;
                endD   = dataSource.endDate;
            else
                if isempty(freq)
                    freq = dataSource.frequency;
                else
                    if ischar(freq)
                        freq = nb_date.getFrequencyAsInteger(freq);
                    end
                end
                startD = convert(dataSource.startDate,freq);
                endD   = convert(dataSource.endDate,freq);
            end
            
            if ~isempty(cellInput)

                transBack = 0;
                if ~iscell(cellInput)
                    cellInput = {cellInput};
                    transBack = 1;
                end
                
                cInput = cellInput;
                for ii = start:incr:length(cInput)

                    trans  = 0;
                    obs    = cInput{ii};
                    if ~iscell(obs)
                        obs   = {obs};
                        trans = 1;
                    end
                      
                    for jj = 1:length(obs)
                        
                        date = obs{jj};
                        if ischar(date)
                            ind = strfind(date,'%#');
                            if ~isempty(ind)
                                date = nb_localVariables(dataSource.localVariables,date);
                                try
                                    tested = nb_date.toDate(date,freq);
                                catch
                                    error('nb_graph:LocalVariableError',[mfilename ':: Unsupported date %' date ' for frequency ' nb_date.getFrequencyAsString(freq) ...
                                                     ' given to the property verticalLine with local variable notation.'])
                                end
                            else
                                tested = nb_date.toDate(date,freq);
                            end
                        else
                            tested = nb_date.toDate(date,freq);
                        end
                        
                        if tested < startD 
                      
                            obs{jj}    = startD;                            
                            newMessage = ['The ' propertyName ' (or one of them) starts/ends before the start date of the new data. Reset to ' startD.toString '.'];
                            message    = nb_addMessage(message,newMessage);  
                            
                        elseif tested > endD
                            
                            obs{jj}    = endD;
                            newMessage = ['The ' propertyName ' (or one of them) starts/ends after the end date of the new data. Reset to ' endD.toString '.'];
                            message    = nb_addMessage(message,newMessage);

                        end
                        
                    end

                    if trans 
                        obs = obs{1};
                    end
                    
                    cInput{ii} = obs;

                end
                cellInput = cInput;

                if transBack
                    cellInput = cellInput{1};
                end
                
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Find the default x-ticks spacing
        -------------------------------------------------------------------
        %}
        function spacing = findXSpacing(startGraph,endGraph)
            
            periods = endGraph - startGraph + 1;
            
            if periods < 0
                error([mfilename ':: Number of periods cannot be negative.'])
            end
            
            spacing = round(periods/8);
            if spacing == 0 
                spacing = 1;
            end
            
        end
        
        function obj = unstruct(s)
            
            obj       = nb_graph_ts();
            obj.DB    = nb_ts.unstruct(s.DB);
            frequency = obj.DB.frequency;
            
            fields = fieldnames(s);
            for ii = 1:length(fields)
                
                switch fields{ii}
                
                    case 'annotation'

                        ann = s.annotation;
                        if isstruct(ann)
                            ann = nb_annotation.fromStruct(ann);
                        elseif iscell(ann)
                            for jj = 1:length(ann)
                                if isstruct(ann{jj})
                                    ann{jj} = nb_annotation.fromStruct(ann{jj});
                                else
                                    if isvalid(ann{jj})
                                        ann{jj} = nb_annotation.fromStruct(ann{jj});
                                    end
                                end
                            end
                        end
                        obj.annotation = ann;
                        
                    case 'barShadingDate'
                        
                        if ischar(s.barShadingDate)
                            ind  = strfind(s.barShadingDate,'%#');
                            if isempty(ind)
                                try
                                    obj.barShadingDate = nb_date.toDate(s.barShadingDate,frequency);
                                catch Err
                                    if strcmpi(Err.identifier,'nb_date:improperDate')
                                        date               = nb_date.date2freq(obj.barShadingDate);
                                        obj.barShadingDate = toString(convert(date,frequency));
                                    else
                                        rethrow(Err);
                                    end
                                end
                            else
                                obj.barShadingDate = s.barShadingDate;
                            end
                        else
                            bDate = s.barShadingDate;
                            for jj = 2:2:length(bDate)
                                ind = strfind(bDate{jj},'%#');
                                if isempty(ind)
                                    try
                                        bDate{jj} = nb_date.toDate(bDate{jj},frequency);
                                    catch Err
                                        if strcmpi(Err.identifier,'nb_date:improperDate')
                                            date      = nb_date.date2freq(bDate{jj});
                                            bDate{jj} = toString(convert(date,frequency));
                                        else
                                            rethrow(Err);
                                        end
                                    end
                                end
                            end
                            obj.barShadingDate = bDate;
                        end
                        
                    case {'dashedLine','defaultFans','endGraph','startGraph','stopStrip'}
                        
                        if nb_contains(s.(fields{ii}),'%#')
                            obj.(fields{ii}) = s.(fields{ii});
                        else
                            try
                                obj.(fields{ii}) = nb_date.toDate(s.(fields{ii}),frequency);
                            catch Err
                                if strcmpi(Err.identifier,'nb_date:improperDate')
                                    date             = nb_date.date2freq(s.(fields{ii}));
                                    obj.(fields{ii}) = toString(convert(date,frequency));
                                else
                                	rethrow(Err);
                                end
                            end
                        end 
                        
                    case 'xTickStart'
                        
                        if nb_contains(s.(fields{ii}),'%#')
                            obj.(fields{ii}) = s.(fields{ii});
                        else
                            obj.(fields{ii}) = nb_date.date2freq(s.(fields{ii}));
                        end 
                        
                    case 'DB'
                        % Already done
                    case 'fanDatasets'
                        if isstruct(s.fanDatasets) && isfield(s,'class')
                            obj.fanDatasets = nb_ts.unstruct(s.fanDatasets);
                        else
                            obj.fanDatasets = s.fanDatasets;
                        end
                    case 'figTitleObjectEng'
                        if isstruct(s.figTitleObjectEng)
                            obj.figTitleObjectEng = nb_figureTitle.unstruct(s.figTitleObjectEng);
                        end
                    case 'figTitleObjectNor'
                        if isstruct(s.figTitleObjectEng)
                            obj.figTitleObjectNor = nb_figureTitle.unstruct(s.figTitleObjectNor);
                        end
                    case 'footerObjectEng'
                        if isstruct(s.figTitleObjectEng)
                            obj.footerObjectEng = nb_footer.unstruct(s.footerObjectEng);
                        end
                    case 'footerObjectNor'
                        if isstruct(s.figTitleObjectEng)
                            obj.footerObjectNor = nb_footer.unstruct(s.footerObjectNor);
                        end
                    case 'simpleRulesSecondData'
                        obj.simpleRulesSecondData = nb_ts.unstruct(s.simpleRulesSecondData);
                    case {'manuallySetColorOrder','manuallySetColorOrderRight','manuallySetLegend','manuallySetEndGraph','manuallySetStartGraph'}
                        obj.(fields{ii}) = s.(fields{ii});
                    otherwise
                        
                        if isprop(obj,fields{ii})
                            obj.(fields{ii}) = s.(fields{ii});
                        end
                        
                end
                
            end
            
        end
        
        function obj = loadobj(s)
        % Overload how the object is loaded from a .mat file      
            obj = nb_graph_ts.unstruct(s);
        end
        
    end
    
    methods (Access=protected,Hidden=true)
       
        varargout = setPropBarShadingDate(varargin)
        varargout = setPropDashedLine(varargin)
        varargout = setPropDefaultFans(varargin)
        varargout = setPropEndGraph(varargin)
        varargout = setPropNanDate(varargin)
        varargout = setPropSimpleRulesSecondData(varargin)
        varargout = setPropStartGraph(varargin)
        
    end
end

