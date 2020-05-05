#Theme for charts

import altair as alt
import cpuc.params as params

def sbw_cpuc():
    # font = 'Calisto MT'    
    font = 'Verdana' # Pro Condensed Semibold'    
    font_size = 12
    title_font_size = 14
    # Colors
    main_palette = params.MAIN_PALETTE
    sequential_palette = ["#4f81bd",
                          "#c0504d",
                          "#9bbb59",
                          "#8064a2",
                          "#4bacc6",
                          "#f79646",
                         ]
    return {
        'config': {
            'text': {
                'font': font,
                'fontSize': font_size,
            },
            'axis': {
                'labelFont': font,
                'labelFontSize': font_size,
                'titleFont': font,
                'titleFontSize': title_font_size,
            },
            'legend': {
                'labelFont': font,
                'labelFontSize': font_size,
                'titleFont': font,
                'titleFontSize': title_font_size,
            },
            'header': {
                'labelFont': font,
                'labelFontSize': font_size,
                'titleFont': font,
                'titleFontSize': title_font_size,
            },
            "range": {
                "category": main_palette,
                "diverging": sequential_palette,
            }
        },
    }

alt.themes.register('sbw_cpuc', sbw_cpuc)
alt.themes.enable('sbw_cpuc')