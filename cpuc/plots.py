#produce plots
#TODO This should be redone using visualization classes
import os.path
import logging

import altair as alt
#import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots

from cpuc.altair_theme import sbw_cpuc
import cpuc.params as params



alt.themes.register('sbw_cpuc', sbw_cpuc)
alt.themes.enable('sbw_cpuc')

fontfamily = "Verdana Pro Condensed Semibold, Verdana"
g_font_size = 16
axis_line_width = 2
grid_line_width = 1
grid_color = 'grey'
axis_color = 'black'
legend_size_increase = 3

# Data Type    Code Description
# quantitative  Q   Number 
# nominal       N   Unordered Categorical
# ordinal       O   Ordered Categorical
# temporal      T   Date/Time

class mvis():
    '''
    SM: Class for containing all the specification information for a visualization using matplotlib and seaborn
    '''
    def __init__(self, *kwargs):
        self.colorsrc = None #string, name of field to determine color groups
        self.fuel = None #kWh, therms, kw
        self.plotfiletype = '.svg' #the file format in which to save the plot: .png | .pdf | .svg
        self.rmax = None
        self.scalekwh = [1000000000, ' Billion '] #axis scale for kwh plots
        self.scalethm = [1000000, ' Million '] #axis scale for thm plots
        self.scalekw = [1000, ' Thousand '] #axis scale for kw plots
        self.type = None
        self.xaxissrc = None #source for x axis
        self.yaxissrc = None #source for y axis      

        
class pvis():
    '''
    SM: Class for containing all the specification information for a visualization using plotly
    '''
    def __init__(self, *kwargs):
        self.annotationfont = {'family':'Verdana Pro Condensed Semibold, Verdana', 
                               'size':16, 
                               'color':'Black'}
        self.annotation = {'x': 1, 
                           'y': None, 
                           'showarrow': False, 
                           'text': None, 
                           'font': self.annotationfont, 
                           'align': 'center', #"left" | "center" | "right"
                           'valign': 'middle', #"top" | "middle" | "bottom"
                           'borderpad': 4, #Sets the padding (in px) between the `text` and the enclosing border
                           'bordercolor': 'Black', 
                           'borderwidth': 1,
                           'bgcolor': 'white'
                            }         
        self.captions = None #list, captions created by engineer requesting plot. used to find type of fuel being plotted
        self.colors = params.MAIN_PALETTE #list of colours to be used for the plot
        self.colorsrc = None #string, name of field to determine color groups
        self.datasrc = None #string, name of field to source values to plot
        self.datasrckwh = None #string, name of field to source values for kwh data subset
        self.datasrcthm = None #string, name of field to source values for thm data subset
        self.datasrckw = None #string, name of field to source values for kw data subset
        self.fuelsrc = None #string, name of field to identify fuel being plotted when multiple plots are done one after another
        self.font = {'family':'Verdana Pro Condensed Semibold, Verdana', 
                     'size':16, 
                     'color':'Black'} 
        self.labelsrc = None #string, name of field to create label for each (x,y)pair
        self.labelposition = 'outside' #Specifies the location of the `text` ( "inside" | "outside" | "auto" | "none" ) 

        #legend properties
        self.showlegend = True            
        self.legendfont = {'family':'Verdana Pro Condensed Semibold, Verdana', 
                                   'size':16,  
                                   'color':'Black'}
        self.legend = {'bgcolor':None, #background colour, 
                       'bordercolor': 'Black', 
                       'borderwidth': 0, 
                       'font':self.legendfont, 
                       'orientation': 'v', 
                       'traceorder': 'normal', #"reversed", "grouped", "reversed+grouped", "normal"
                       'x': 0, 
                       'xanchor': 'auto', #"auto" | "left" | "center" | "right"01 
                       'y': 1, 
                       'yanchor': 'auto', #"auto" | "top" | "middle" | "bottom"
                       }          

        #marker propertoes
        self.mode = 'markers'
        self.markersymbols = 'symbols'
        self.markersize = 15
        self.markercolor = None #Sets themarkercolor. It accepts either a specific color or an array of numbers that are mapped to the colorscale relative to the max and min values of the array
        self.markerline = {'width': None, #Sets the width (in px) of the lines bounding the marker points.
                           'color':[]#Sets themarker.linecolor. It accepts either a specific color or an array of numbers that are mapped to the colorscale, 
                           }
        self.markersymbol = {'circle', }
        self.marker = {'color':self.markercolor, 
                       'line':self.markerline, 
                       }

        self.name = None     
        self.plotfiletype = '.svg' #the file format in which to save the plot

        #plot properties
        self.plotbgcolor = 'White' #background colour    
        self.plotcols = 1
        self.plotfont = {'family':'Verdana Pro Condensed Semibold, Verdana', 
                     'size':16, 
                     'color':'Black'}   
        self.plotrows = 1
        self.plotxaxeshare = True
        self.plotwdth = 1000 #width of graph
        self.plotht = 0.6*self.plotwdth

        self.rmax = None #the minimum of the max of xaxissrc and yaxissrc
        self.scalekwh = [1000000000, 'Billion'] #axis scale for kwh plots
        self.scalethm = [1000000, 'Million'] #axis scale for thm plots
        self.scalekw = [1000, 'Thousand'] #axis scale for kw plots

        #title properties   
        self.title_font = {'family':'Verdana Pro Condensed Semibold', 
                                  'size':20,  
                                  'color':'Black'}
        self.titletext = None
        self.title = {'text': self.titletext,
                      'font':self.title_font, 
                      'xref': None, 
                      'x':None, 
                      'yref':None, 
                      'y':None, 
                      'xanchor':None, 
                      'yanchor':None, 
                      'pad':{'t':0, 'r':0, 'b':0, 'l':0}}

        self.type = None #string, type of chart to be plotted ('bar' /'scatter' )
        self.xaxissrc = None #source for x axis
        self.yaxissrc = None #source for y axis        
        



#        self.bordercolor = None #border for graph
#        self.borderwidth = 1  #line width of graph border        

#        self.barmode = None #'group' to arrange side by side; 'stack' to arrange vertically    
#        self.category_orders = [] #provides labels for different facet fields ??check if ok to place open close brackets or use none

#        self.facet_col = None #field that determines facets for arranging plots in multiple columns
#        self.facet_row = None #field that determines facets for arranging plots in multiple rows   
#        self.xaxis_tickangle = None
        
class axis():
#axis properties
    def __init__(self, text = None, tformat = None, *kwargs):
        self.color = 'Black'
        self.visible = True
        self.tickformat = tformat
        self.titlefont = {'family':'Verdana Pro Condensed Semibold', 
                                  'size':18,  
                                  'color':'Black'}
        self.titletext = text
        self.title = {'font':self.titlefont,
                                   'text':self.titletext}
        self.axis = {'visible':self.visible, 
                     'color':self.color, 
                     'title':self.title, 
                     'tickformat':self.tickformat}



#class annotate(): TODO: couldn't get this to work. need to revisit as can have multiple annotations per graph
##annotation properties - used to create any annotation(s) needed in the plot
#    def __init__(self, *kwargs):
#        self.annotationfont = {'family':'Verdana Pro Condensed Semibold', 
#                               'size':16, 
#                               'color':'Black'}
#        self.props = {'x': 1, 
#                           'y': None, 
#                           'showarrow': False, 
#                           'text': None, 
#                           'font': self.annotationfont, 
#                           'align': 'center', #"left" | "center" | "right"
#                           'valign': 'middle', #"top" | "middle" | "bottom"
#                           'borderpad': 4, #Sets the padding (in px) between the `text` and the enclosing border
#                           'bordercolor': 'Black', 
#                           'borderwidth': 1, 
#                            } 



        
def editptitle(self, family=None, size=None, color=None, text = None, xref = None, yref = None, x = None, y = None, xanchor = None, yanchor = None, t=None, r=None, b=None, l=None):
    if not family and size and color:
        font = self.layout_title_font 
    else:
        font = {'family':family, 'size':size, 'color':color}
    if not t and r and b and l:
        pad = {}
    else:
        if not t:
            t=0
        if not r:
            r=0
        if not b:
            b=0
        if not l:
            l=0
        pad = {'t':t, 'r':r, 'b':b, 'l':l}
    self.layout_title = {'font':font, 'text':text, 'xref':xref, 'yref':yref, 'x':x, 'y':y, 'xanchor':xanchor, 'yanchor':yanchor, 'pad':pad}
    return self.layout_title

          
'''-------------------'''        
class vis():
    """
    Class for containing all the specification information for a visualization
    """
    def __init__(self, **kwargs):
        self.type = None #bar, point
        self.rule = False
        self.rule_field = None
        self.rule_type = 'mean'
        self.source = None
        self.x = None
        self.y = None
        self.size = 18
        self.size_src = None
        self.size_legend = True
        self.sizecolor = True
        self.binspec = None
        self.color_src = None
        self.color_legend = True
        self.column_src = None
        self.color = None
        self.name = None
        self.path = None
        self.output_ext = 'svg'
        self.c_width = 150
        self.c_height = 150
        self.facet_title = False
        self.facet_labelOrient = 'top'
        self.facet_cols = None
        self.legend_title = False
        self.legend_orient = 'right'
        self.filled = True
        
class pspecannotat():
    def __init__(self, *kwargs):
        self.x= 1
        self.y= 1, 
        self.showarrow = False
        self.text= None
        self.bordercolor = "Black",
        self.borderwidth = 1

class d_axis():
    """
    Class for containing all the specification information for a visualization domain axis like x or y
    """
    def __init__(self, **kwargs):
        # self.type = None #x or y
        self.source = None #string for field can also include type of data, example myfield:Q
        self.bin = None
        self.title = None   #leave blank to use field as title
        self.axis = None #can be a dict of properties like title, labels, ticks, etc
        self.resolvescale = 'shared'  #independent is the other option

def facet(obj:vis):
    """
    create a faceted visualization
    """
    source = obj.source
    v = f"alt.Chart().encode(alt.X('{obj.x.source}',"
    # if obj.x.title:
    #     v = v + f"title='{obj.x.title}',"

    #           scale=alt.Scale(zero=False),
    v = v + f"axis=alt.Axis(title='{obj.x.title}', grid=False, labels=False, ticks=False)), alt.Y('{obj.y.source}',"
    if obj.y.title:
        v = v + f"title='{obj.y.title}',"        
    
    v = v + f")).properties( \
        width={obj.c_width},  \
        height={obj.c_height})"
    base = eval(v)
    # print(f'base string: {v}')

    if obj.rule:
        v = f"alt.Chart().mark_rule(color='red').encode(y='{obj.rule_type}({obj.rule_field}):Q')"
    rule = eval(v)
    # print(f'rule string: {v}')

    if obj.type == 'point':
        v = f"base.mark_point(filled={obj.filled}, size={obj.size}).encode("
        if obj.size_src:
            v = v + f"size=alt.Size('{obj.size_src}'"
            if not obj.size_legend:
                v = v + f", legend=None"
            if obj.binspec:
                #coould be in the form of bin=alt.Bin(extent=[14, 30], step=3)
                v = v + f', {obj.binspec}'            
            v = v + "),"
        if obj.sizecolor:
            v = v + f"color=alt.Color('{obj.color_src}'"
        if not obj.color_legend:
            v = v + f", legend=None"
        
        v = v + "))"
    
        points = eval(v)
        # print(f'points string: {v}')
        v = f"alt.layer(points "
        if obj.rule:
            v = v + ' + rule, '
        v = v + "data=source)"
    elif obj.type == 'bar':
        v = f"base.mark_bar(size={obj.size}).encode( \
            color='{obj.x.source}')"
        bars = eval(v)
        # print(f'bars string: {v}')
        v = f"base.mark_text(dy=-8).encode( \
            text='{obj.y.source}')"
        text = eval(v)
        # print(f'text string: {v}')
        v = f"alt.layer(bars, text "
        if obj.rule:
            v = v + ', + rule, '
        else:
            v = v + ', ' 
        v = v + "data=source)"

    v = v + f".facet( \
        column='{obj.column_src}', \
        ).configure_axis( \
            domainWidth=1, \
        ).configure_header("
    if not obj.facet_title:
        v = v + f"title=None,"
    
    v = v + f"labelOrient='{obj.facet_labelOrient}').configure_legend("
    if not obj.legend_title:
        v = v + 'title=None,'
    v = v + f"orient='{obj.legend_orient}' \
        ).resolve_scale( \
            y='{obj.x.resolvescale}', \
            x='{obj.y.resolvescale}' \
        )"
        
    #generate viz
    print(f'final string: {v}')
    viz = eval(v)
    #write viz out
    filepath = os.path.join(obj.path, obj.name + '.' + obj.output_ext)
    #TODO see if can save to fileobject
    viz.save(filepath, webdriver='firefox')
    # print(f'saved chart {filepath}')
    
    
def mksubplot(fig, trace, x, y):
    '''SM: inserts subplot into row and col specified by a and y respectively'''
    fig.append_trace(trace, x, y)
  
    
def mkplot1(df, spec, outputfolder):
    '''
    SM: creates 1x1 plot with n number of subplots. replaces second half (the non data processing part) of create_ciac2018_ExSum_grrntgr_bar written by GH. 
        df = dataframe to use
        spec = object with all the properties needed for the plot to be built
        outputfolder = folder in which plot is saved
    '''
    
    if len(spec.colors) < df[spec.colorsrc ].nunique():
        print('oops, need more colours for the plot') #TODO need to exit function here
    else:
        elements = df[spec.xaxissrc].nunique()
        lcolors = [[color] * elements for color in spec.colors]      

           
    for caption in spec.captions:
        #Build plot caption     
        if 'kwh' in caption.lower() or 'electric' in caption.lower():
            fuel = 'kWh'
            spec.y = axis(text = f"<b>{spec.scalekwh[1]}s of kWh/Year</b>", tformat = '.1f')
#            spec.y.tickformat = '.1f'
        elif ('therm' in caption.lower()) or ('thm' in caption.lower()) or ('therms' in caption.lower() or 'gas' in caption.lower()):
            fuel = 'therms' #TODO make this generic using max value of chart
            spec.y = axis(text = f"<b>{spec.scalethm[1]}s of Therms/Year</b>", tformat = '.0f')
#            spec.y.tickformat = '.0f'
        elif 'kw' in caption.lower():
            fuel = 'kW'        
            spec.y = axis(text = f"{spec.scalekw[1]}s of {fuel}/Year")
        else:
            msg =f'cannot match caption for {caption}'
            logging.critical(msg)
            print(msg)
            continue
        i=0   
    
        #splice dataframe to get fuel relevant data + get height of plot (determined by max value on yaxis)
        if fuel.lower() == 'kwh':
            try:
                dfloop = df[df[spec.fuelsrc].isin(['kWh', 'kwh', 'KWH'])].copy()
                spec.annotation['y'] = dfloop[spec.datasrckwh].max()            
            except:
                msg = f'cannot find fuel {fuel} in dataframe {spec.fuelsrc}'
                logging.warning(msg)
                print(msg)
        elif fuel.lower() == 'therms':
            try:
                dfloop = df[df[spec.fuelsrc].isin(['therm', 'therms', 'thm', 'Therm', 'Therms', 'THERM', 'THERMS', 'THM'])].copy() 
                spec.annotation['y'] = dfloop[spec.datasrcthm].max()
            except:
                msg = f'cannot find fuel {fuel} in dataframe {spec.fuelsrc}'
                logging.warning(msg)
                print(msg)
        elif fuel.lower() == 'kw':
            try:
                dfloop = df[df[spec.fuelsrc].isin(['kW', 'kw', 'KW'])].copy()
                spec.annotation['y'] = dfloop[spec.datasrckw].max()     
            except:
                msg = f'cannot find fuel {fuel} in dataframe {spec.fuelsrc}'
                logging.warning(msg)
                print(msg)
                continue
        
        #build trace         
        traces = []
        if 'kw' in fuel.lower():
            textsizeadj = -2
        else:
            textsizeadj = 0

        for color in dfloop[spec.colorsrc].unique():
            i += 1    
            dfchart = dfloop[dfloop[spec.colorsrc]==color]
            if spec.type == 'bar':           
                trace = go.Bar(x=dfchart[spec.xaxissrc], 
                               y=dfchart[spec.datasrc + fuel], 
                               text=dfchart[spec.labelsrc],
                               textfont=dict(size=g_font_size + legend_size_increase + textsizeadj),
                               textposition = spec.labelposition,
                               marker=dict(color = lcolors[i-1]),
                               name=color)       
            elif spec.type == 'scatter':
                msg = f'not ready for {spec.type} plots yet'
                logging.warning(msg)
                print(msg)
            else:
                msg = f'not ready for {spec.type} plots yet'
                logging.warning(msg)
                print(msg)
            traces.append(trace)
    
        #create specs for subplots
        fig = go.Figure()
        fig = make_subplots(rows=spec.plotrows, 
                            cols=spec.plotcols, 
                            shared_xaxes=spec.plotxaxeshare)
        
        #update specs for plot: background color, width, height and font
        fig.update_layout(plot_bgcolor=spec.plotbgcolor, 
                          width=spec.plotwdth, 
                          height=spec.plotht, 
                          font=spec.plotfont)
    
        #insert subplots into specified x,y positions into plot
        for trace in traces:
            mksubplot(fig, trace, x=1, y=1) #may want to make this more flexible to allow for different arrangements
       
        fig.update_xaxes(
                showline=True, linewidth=axis_line_width, linecolor=axis_color, mirror=True,
                tickfont=dict(family=fontfamily, size=g_font_size + legend_size_increase),
        )

        #add yaxis title. TODO need to find GH's for loop and use it instead
        fig.update_yaxes(title_text = spec.y.titletext,
                        tickformat = spec.y.tickformat,
                        tickfont=dict(family=fontfamily, size=g_font_size + legend_size_increase),
                        showgrid=True, gridwidth=grid_line_width, gridcolor=grid_color, 
                        showline=True, linewidth=axis_line_width, linecolor=axis_color, mirror=True, 
                        row=1, 
                        col=1) 
     
        #adding legend and plot caption
        fig.update_layout(legend=spec.legend,
                            margin=dict(
                                    t=0,
                                    b=0,
                                    l=0,
                                    r=0,
                                    pad=0
                                ),
                            annotations=[spec.annotation])
        
        #saving plot as image to output folder
        filename = os.path.join(outputfolder, caption + spec.plotfiletype)
        fig.write_image(filename)                
        
        # fig.show()

