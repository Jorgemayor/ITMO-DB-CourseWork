import {Controller,} from 'react-hook-form';

import {FormField} from './FormField';

export const FormFieldControl = ({name, control, ...inputProps}) => {
    return (
        <Controller
            name={name}
            control={control}
            render={({field, fieldState: {error}}) => (
                <FormField {...field} id={name} errorText={error?.message} {...inputProps} />
            )}
        />
    );
};
