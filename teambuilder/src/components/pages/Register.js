import React, {useMemo, useState} from 'react'
import '../../App.css'
import {useForm} from "react-hook-form";
import {zodResolver} from "@hookform/resolvers/zod";
import z from 'zod';
import {Alert, Button, Container, Paper, Stack, Typography} from "@mui/material";
import {FormFieldControl} from "../FormFieldControl";
import {post} from "../../utils/fetcher";
import {useAuthSession} from "../../hooks/useAuthSession";
import {useNavigate} from "react-router-dom";

function Register() {
    const { setSession } = useAuthSession();
    const navigate = useNavigate();
    const [error, setError] = useState('');

    const schema = useMemo(
        () =>
            z.object({
                username: z.string().min(3),
                email: z.string().email().min(3),
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
            const result = await post('/api/trainer/signup', values);
            setSession({ session: result.trainer, token: result.token });
            navigate('/', { replace: true });
        } catch (e) {
            console.error('Error logging in:', e);
            setError('Error signing up!');
        }
    };

    return (
        <>
            <Container sx={{my: 12, display: 'flex', justifyContent: 'center'}}>
                <Paper elevation={1} sx={{py: 3, px: 4, minWidth: '400px', maxWidth: '500px'}}>
                    <Typography variant="h4" sx={{mb: 4, textAlign: 'center'}}>REGISTER</Typography>
                    {error && <Alert sx={{my: 3}} severity="error">{error}</Alert>}
                    <form onSubmit={handleSubmit(onSubmit)}>
                        <Stack spacing={4}>
                            <FormFieldControl name="username" control={control} label="Username" type="text"/>
                            <FormFieldControl name="email" control={control} label="Email" type="email"/>
                            <FormFieldControl name="password" control={control} label="Password" type="password"/>
                            <Button variant="contained" type="submit">
                                Sign up
                            </Button>
                        </Stack>
                    </form>
                </Paper>
            </Container>
        </>
    )
}

export default Register
