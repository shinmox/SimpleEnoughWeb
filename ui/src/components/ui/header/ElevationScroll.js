// https://material-ui.com/components/app-bar/#elevate-app-bar

import React from 'react';
import useScrollTrigger from '@material-ui/core/useScrollTrigger';

export default function ElevationScroll(props) {
    const { children, window } = props;

    const trigger = useScrollTrigger({
        disableHysteresis: true,
        threshold: 0
    });

    return React.cloneElement(children, {
        elevation: trigger ? 4 : 0,
    });
}
