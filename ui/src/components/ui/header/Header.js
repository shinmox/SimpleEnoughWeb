import React from 'react';
import AppBar from '@material-ui/core/AppBar';
import ToolBar from '@material-ui/core/Toolbar';
import ElevationScroll from './ElevationScroll';
import ScrollTop from './BackToTop';
import Fab from '@material-ui/core/Fab';
import KeyboardArrowUpIcon from '@material-ui/icons/KeyboardArrowUp';
import Typography from '@material-ui/core/Typography'
import { makeStyles } from '@material-ui/styles'
import Logo from '../../../assets/Logo.svg'

const useStyles = makeStyles(theme => ({
    toolbarMargin: {
        ...theme.mixins.toolbar
    },
    logo: {
        height: "4em"
    }
}))

export default function Header(props) {
    const classes = useStyles()
    return (
        <React.Fragment>
            <ElevationScroll>
                <AppBar id="back-to-top-anchor" position="fixed">
                    <ToolBar>
                        <img alt="company logo" className={classes.logo} src={Logo}/>
                        <Typography variant="h4">
                            Simple Enough
                        </Typography>
                    </ToolBar>
                </AppBar>
            </ElevationScroll>
            <div className={classes.toolbarMargin} />
            <ScrollTop {...props}>
                <Fab color="secondary" size="small" aria-label="scroll back to top">
                    <KeyboardArrowUpIcon />
                </Fab>
            </ScrollTop>
        </React.Fragment>
    )
}
