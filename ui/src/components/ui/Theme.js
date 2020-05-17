import { createMuiTheme } from '@material-ui/core/styles'
import { blue } from '@material-ui/core/colors';

const logoFront = "#00FF85";
const logoBack = "#152742";
const siteBack = "#90A5BE";
const siteFront = "#000000";

export default createMuiTheme({
    palette: {
        common: {
            logoFront: logoFront,
            logoBack: logoBack
        },
        primary: {
            main: logoBack,
            contrastText: logoFront
        },
        secondary: {
            main: siteFront,
            contrastText: siteBack
        }
    }
});
