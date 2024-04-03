import React, {useMemo} from 'react'
import '../../App.css'
import {useForm} from "react-hook-form";
import {zodResolver} from "@hookform/resolvers/zod";
import z from 'zod';
import {Button, Container, Paper, Stack, Typography} from "@mui/material";
import {FormFieldControl} from "../FormFieldControl";
import {post} from "../../utils/fetcher";

function Login() {
    const schema = useMemo(
        () =>
            z.object({
                username: z.string().min(3),
                password: z.string().min(3),
            }),
        [],
    );

    const {handleSubmit, control} = useForm({
        mode: 'onSubmit',
        reValidateMode: 'onChange',
        resolver: zodResolver(schema),
    });

    const onSubmit = async (values) => {
        try {
            const result = await post('/api/trainer/login', values);
            console.log('result', result);
        } catch (e) {
            console.error('Error logging in:', e);
        }
    };

    return (
        <>
            <Container sx={{my: 12, display: 'flex', justifyContent: 'center'}}>
                <Paper elevation={1} sx={{py: 3, px: 4, minWidth: '400px', maxWidth: '500px'}}>
                    <Typography variant="h4" sx={{mb: 4, textAlign: 'center'}}>LOGIN</Typography>
                    <form onSubmit={handleSubmit(onSubmit)}>
                        <Stack spacing={4}>
                            <FormFieldControl name="username" control={control} label="Username" type="text"/>
                            <FormFieldControl name="password" control={control} label="Password" type="password"/>
                            <Button variant="contained" type="submit">
                                Sign in
                            </Button>
                        </Stack>
                    </form>
                </Paper>
            </Container>
        </>
    )
}

export default Login
