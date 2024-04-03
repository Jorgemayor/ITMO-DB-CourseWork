import { forwardRef } from 'react';
import {FormControl, FormLabel, Input, Typography} from "@mui/material";

export const FormField = forwardRef((props, ref) => {
    const { id, label, errorText, ...inputProps } = props;
    return (
        <FormControl id={id}>
            <FormLabel>{label}</FormLabel>
            <Input ref={ref} {...inputProps} />
            {errorText && <Typography color="red" mt={1}>{errorText}</Typography>}
        </FormControl>
    );
});
FormField.displayName = 'FormField';
